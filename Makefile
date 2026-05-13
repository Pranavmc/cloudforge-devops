.DEFAULT_GOAL := help

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize terraform
	cd terraform && terraform init

fmt: ## Format terraform
	terraform fmt -recursive terraform/

validate: ## Validate terraform
	cd terraform && terraform validate

plan: ## Plan terraform
	cd terraform && terraform plan

apply: ## Apply terraform
	cd terraform && terraform apply -auto-approve

destroy-k8s: ## Destroy k8s resources
	kubectl delete -f kubernetes/ --ignore-not-found=true

destroy-infra: ## Destroy infra
	cd terraform && terraform destroy -auto-approve

destroy: destroy-k8s destroy-infra ## Destroy everything

provision: ## Run Ansible playbook
	ansible-playbook ansible/site.yml -v

ping: ## Ping all nodes
	ansible all -m ping

deploy: ## Deploy k8s manifests
	kubectl apply -f kubernetes/

rollout: ## Check rollout status
	kubectl rollout status deployment/devops-api -n devops-api

logs: ## Get logs
	kubectl logs -l app=devops-api -n devops-api --tail=100 -f

pods: ## Get pods
	kubectl get pods -n devops-api -o wide

check: ## Run validation script
	bash scripts/validate.sh

build: ## Build docker image
	cd app && docker build -t YOURDOCKERUSERNAME/devops-api:latest .

test: ## Run app tests
	cd app && npm test

lint: ## Run app linting
	cd app && npx eslint src/
