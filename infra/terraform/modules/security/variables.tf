variable "project_name" {
  description = "Prefix applied to every resource name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security group belongs to"
  type        = string
}

variable "my_ip" {
  description = "Admin IP in CIDR notation (e.g. 1.2.3.4/32) — restricts SSH and k3s API"
  type        = string
}
