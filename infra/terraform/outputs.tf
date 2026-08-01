output "control_plane_public_ip" {
  description = "Public IP of the control-plane node — use this in inventory.ini and for kubectl"
  value       = module.compute.control_plane_public_ip
}

output "control_plane_private_ip" {
  description = "Private IP of the control-plane node — workers join via this address"
  value       = module.compute.control_plane_private_ip
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes — use these in inventory.ini"
  value       = module.compute.worker_public_ips
}

output "worker_private_ips" {
  description = "Private IPs of the worker nodes"
  value       = module.compute.worker_private_ips
}
