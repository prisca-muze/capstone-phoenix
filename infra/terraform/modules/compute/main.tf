# Look up the latest Ubuntu 22.04 LTS AMI from Canonical (owner ID: 099720109477)
# most_recent = true picks the latest patched release automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Upload the public key to AWS — instances reference it by key_name at launch
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

################################ CONTROL PLANE ###################################

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.server_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.main.key_name

  # Root volume: 20GB is enough for k3s + system; gp3 is cheaper than gp2
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-control-plane"
    project = var.project_name
    role    = "server"
  }
}

################################### WORKERS ######################################

resource "aws_instance" "workers" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-worker-${count.index}"
    project = var.project_name
    role    = "agent"
  }
}
