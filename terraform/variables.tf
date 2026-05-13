variable "project_name" {
  description = "Name of the project used for resource naming and tagging."
  type        = string
  default     = "devops-automation"
}

variable "environment" {
  description = "Deployment environment name used for tagging resources."
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Availability zones used for subnet placement."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "bastion_allowed_ip" {
  description = "CIDR block allowed to SSH into the bastion host."
  type        = string
  default     = "0.0.0.0/0"
}
