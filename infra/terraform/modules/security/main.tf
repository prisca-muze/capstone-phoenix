# Security group — the cloud-level firewall for all 3 nodes
resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-sg"
  description = "Firewall rules for the k3s cluster nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project_name}-sg"
    project = var.project_name
  }
}

# SSH — admin IP only (your machine). Never open to 0.0.0.0/0.
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.cluster.id
  description       = "SSH from admin IP only"
}

# HTTP — open to the world so the ingress controller can serve traffic
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "HTTP inbound (redirects to HTTPS via ingress)"
}

# HTTPS — open to the world for TLS traffic
resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "HTTPS inbound"
}

# k3s API server — admin IP only. NEVER open to 0.0.0.0/0 (auto-fail violation).
resource "aws_security_group_rule" "k3s_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.cluster.id
  description       = "k3s API server - kubectl access from admin IP only"
}

# Internal — all traffic between nodes in the same security group (kubelet, VXLAN, etcd, etc.)
resource "aws_security_group_rule" "internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.cluster.id
  description              = "Unrestricted inter-node traffic (same SG)"
}

# Egress — all outbound allowed (nodes need internet to pull k3s, apt packages, images)
# AWS security groups have NO default egress in Terraform — must be explicit.
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "All outbound traffic allowed"
}
