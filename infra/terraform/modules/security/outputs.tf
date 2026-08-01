output "security_group_id" {
  description = "ID of the cluster security group — passed to the compute module"
  value       = aws_security_group.cluster.id
}
