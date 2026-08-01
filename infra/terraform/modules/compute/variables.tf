variable "project_name" {
  description = "Prefix applied to every resource name"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet instances are launched into"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group attached to all instances"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Absolute path to the SSH public key uploaded as an AWS key pair"
  type        = string
}

variable "server_instance_type" {
  description = "EC2 instance type for the control-plane node"
  type        = string
}

variable "worker_instance_type" {
  description = "EC2 instance type for each worker node"
  type        = string
}
