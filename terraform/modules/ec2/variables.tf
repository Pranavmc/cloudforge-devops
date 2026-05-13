variable "project_name" {
  description = "Name of the project used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment name used for tagging resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EC2 resources will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for public-facing resources."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for internal resources."
  type        = list(string)
}

variable "bastion_allowed_ip" {
  description = "CIDR block allowed to SSH into the bastion host."
  type        = string
}
