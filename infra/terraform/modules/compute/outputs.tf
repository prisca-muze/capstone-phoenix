output "control_plane_public_ip" {
  description = "Public IP of the control-plane — goes into inventory.ini and kubeconfig"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Private IP of the control-plane — workers join via this address"
  value       = aws_instance.control_plane.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes — goes into inventory.ini"
  value       = aws_instance.workers[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of the worker nodes"
  value       = aws_instance.workers[*].private_ip
}
