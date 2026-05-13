# DevOps Automation Project

## Architecture
```text
Developer → GitHub Push → GitHub Actions CI
GitHub Actions CI → Docker Hub (push image)
GitHub Actions CI → Kubernetes (kubectl apply)
Terraform → AWS VPC → Public Subnet (Bastion) + Private Subnets (K8s nodes)
Ansible → via Bastion → K8s Master + Workers
K8s Master + Workers → run devops-api pods
Prometheus → scrapes /metrics from pods
Grafana → visualizes Prometheus data
```

## Prerequisites
| Tool | Version | Install command |
|------|---------|-----------------|
| Terraform | 1.5+ | `brew install terraform` |
| Ansible | 2.14+ | `pip install ansible` |
| kubectl | 1.28 | `brew install kubectl` |
| AWS CLI | 2.x | `brew install awscli` |
| Docker | 24+ | `brew install docker` |
| Python | 3.8+ | `brew install python` |
| Node.js | 18+ | `brew install node@18` |
| Helm | 3.12+ | `brew install helm` |
| jq | Latest | `brew install jq` |
| gh | Latest | `brew install gh` |

## Quick Start
1. **Clone repo and install prerequisites**
2. **Configure AWS credentials**: `aws configure`
3. **Generate SSH key**: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops-key`
4. **Create S3 bucket and DynamoDB table**:
   ```bash
   aws s3 mb s3://devops-tf-state-YOURACCOUNTID --region us-east-1
   aws s3api put-bucket-versioning --bucket devops-tf-state-YOURACCOUNTID --versioning-configuration Status=Enabled
   aws dynamodb create-table --table-name devops-tf-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```
5. **Infrastructure**: `cd terraform && terraform init && terraform apply`
6. **Inventory**: Update `ansible/inventory/hosts.ini` with terraform output values
7. **Provision**: `make provision`
8. **Build & Push**: `make build` (after updating image name)
9. **Deploy**: `make deploy`
10. **Verify**: `make check`

## Directory Structure
| File/Directory | Purpose |
|----------------|---------|
| `Makefile` | Command shortcuts for project automation. |
| `README.md` | Project documentation and architecture. |
| `.github/workflows` | CI/CD pipeline definitions. |
| `terraform/` | Infrastructure as Code for AWS. |
| `ansible/` | Server configuration and K8s setup. |
| `app/` | Node.js REST API source code. |
| `kubernetes/` | K8s deployment manifests. |
| `scripts/` | Validation and utility scripts. |

## GitHub Secrets Reference
| Secret Name | Description | How to obtain |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | IAM Console |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | IAM Console |
| `AWS_REGION` | AWS Region | `us-east-1` |
| `DOCKERHUB_USERNAME` | Docker Hub Username | Docker Hub account |
| `DOCKERHUB_TOKEN` | Docker Hub PAT | Docker Hub settings |
| `KUBECONFIG_B64` | Base64 Kubeconfig | `cat ~/.kube/config | base64 -w 0` |
| `SLACK_WEBHOOK_URL` | Slack Webhook | Slack App settings |

## Troubleshooting
1. **"Error: No valid credential sources found"** — Run `aws configure`.
2. **"Error acquiring the state lock"** — Run `terraform force-unlock <ID>`.
3. **"UNREACHABLE - Connection timed out"** — Check SG rules for Bastion and SSH key.
4. **"[ERROR] failed to run Kubelet"** — Run `swapoff -a`.
5. **"node NotReady"** — Check CNI installation with `kubectl get pods -n kube-system`.
6. **"ImagePullBackOff"** — Check Docker Hub credentials in K8s.
7. **"0/2 nodes are available: pod has unbound PersistentVolumeClaims"** — Ensure StorageClass is defined.
8. **"deadline exceeded"** — Increase instance type for Master (t3.medium recommended).

## Teardown
1. `make destroy-k8s`
2. `helm uninstall kube-prometheus-stack -n monitoring`
3. `make destroy-infra`
