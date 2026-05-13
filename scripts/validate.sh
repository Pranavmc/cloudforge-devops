#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

check_result() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL=$((FAIL + 1))
  fi
}

# 1. Terraform state in S3
aws s3 ls s3://devops-tf-state-YOURACCOUNTID/devops-automation/ --region us-east-1 > /dev/null 2>&1
check_result "Terraform state in S3"

# 2. Bastion EC2 instance running
aws ec2 describe-instances --filters "Name=tag:Name,Values=*bastion*" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text | grep -q 'i-'
check_result "Bastion EC2 instance running"

# 3. K8s master EC2 running
aws ec2 describe-instances --filters "Name=tag:Name,Values=*k8s-master*" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text | grep -q 'i-'
check_result "K8s master EC2 running"

# 4. K8s workers EC2 running (expect 2)
WORKER_COUNT=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=*k8s-worker*" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text | wc -w)
[ "$WORKER_COUNT" -eq 2 ]
check_result "K8s workers EC2 running (expect 2)"

# 5. kubectl can reach cluster
kubectl cluster-info > /dev/null 2>&1
check_result "kubectl can reach cluster"

# 6. All k8s nodes are Ready
READY_NODES=$(kubectl get nodes --no-headers | grep Ready | wc -l)
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
[ "$READY_NODES" -eq "$TOTAL_NODES" ] && [ "$TOTAL_NODES" -gt 0 ]
check_result "All k8s nodes are Ready"

# 7. devops-api namespace exists
kubectl get namespace devops-api > /dev/null 2>&1
check_result "devops-api namespace exists"

# 8. Deployment has 3 ready pods
READY_REPLICAS=$(kubectl get deployment devops-api -n devops-api -o jsonpath='{.status.readyReplicas}')
[ "$READY_REPLICAS" -eq 3 ]
check_result "Deployment has 3 ready pods"

# 9. HPA is configured
kubectl get hpa -n devops-api | grep -q devops-api
check_result "HPA is configured"

# 10. Health endpoint responds 200
kubectl port-forward svc/devops-api 9999:80 -n devops-api &>/dev/null &
PF_PID=$!
sleep 5
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9999/health)
kill $PF_PID 2>/dev/null
[ "$STATUS" = "200" ]
check_result "Health endpoint responds 200"

# 11. Prometheus scraping devops-api
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring &>/dev/null &
PF_PID=$!
sleep 5
TARGETS=$(curl -s http://localhost:9090/api/v1/targets | python3 -c "import sys,json; t=json.load(sys.stdin)['data']['activeTargets']; print(len([x for x in t if 'devops-api' in str(x)]))")
kill $PF_PID 2>/dev/null
[ "$TARGETS" -gt 0 ]
check_result "Prometheus scraping devops-api"

echo "Results: $PASS/11 checks passed"

if [ "$PASS" -eq 11 ]; then
  exit 0
else
  exit 1
fi
