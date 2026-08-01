output "vpc_id" {
  description = "ID of the VPC — passed to the security module"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet — passed to the compute module"
  value       = aws_subnet.main.id
}

output "subnet_cidr" {
  description = "CIDR of the subnet — used in UFW internal-allow rule in Ansible"
  value       = aws_subnet.main.cidr_block
}
