variable "project_name" {
  description = "Name of the project used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment name used for tagging resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones used for subnet placement."
  type        = list(string)
}
