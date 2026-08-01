variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Prefix applied to every resource name (e.g. capstone)"
  type        = string
}

variable "my_ip" {
  description = "Your current public IP in CIDR notation (e.g. 1.2.3.4/32) — restricts SSH and k3s API access"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Absolute path to the SSH public key uploaded to AWS as a key pair"
  type        = string
}

variable "server_instance_type" {
  description = "EC2 instance type for the control-plane node"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 instance type for each worker node"
  type        = string
  default     = "t3.small"
}
