terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-tf-state-569085067940"
    key            = "devops-automation/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "devops-tf-lock"
  }
}

provider "aws" {
  region = var.region
}
