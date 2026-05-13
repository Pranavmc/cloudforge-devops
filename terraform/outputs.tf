output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnet_ids
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host."
  value       = module.ec2.bastion_public_ip
}

output "k8s_master_private_ip" {
  description = "Private IP address of the Kubernetes master node."
  value       = module.ec2.k8s_master_private_ip
}

output "k8s_worker_private_ips" {
  description = "Private IP addresses of the Kubernetes worker nodes."
  value       = module.ec2.k8s_worker_private_ips
}

output "bastion_sg_id" {
  description = "ID of the bastion security group."
  value       = module.ec2.bastion_sg_id
}

output "master_sg_id" {
  description = "ID of the Kubernetes master security group."
  value       = module.ec2.master_sg_id
}

output "worker_sg_id" {
  description = "ID of the Kubernetes worker security group."
  value       = module.ec2.worker_sg_id
}
