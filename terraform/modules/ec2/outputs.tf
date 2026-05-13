output "bastion_public_ip" {
  description = "Public IP address of the bastion host."
  value       = aws_instance.bastion.public_ip
}

output "k8s_master_private_ip" {
  description = "Private IP address of the Kubernetes master node."
  value       = aws_instance.k8s_master.private_ip
}

output "k8s_worker_private_ips" {
  description = "Private IP addresses of the Kubernetes worker nodes."
  value       = aws_instance.k8s_workers[*].private_ip
}

output "bastion_sg_id" {
  description = "ID of the bastion security group."
  value       = aws_security_group.bastion_sg.id
}

output "master_sg_id" {
  description = "ID of the Kubernetes master security group."
  value       = aws_security_group.k8s_master_sg.id
}

output "worker_sg_id" {
  description = "ID of the Kubernetes worker security group."
  value       = aws_security_group.k8s_worker_sg.id
}
