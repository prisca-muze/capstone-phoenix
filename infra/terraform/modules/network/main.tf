# VPC — isolated network for the whole cluster
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name    = "${var.project_name}-vpc"
    project = var.project_name
  }
}

# Single public subnet — all 3 nodes live here
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # each instance automatically gets a public IP

  tags = {
    Name    = "${var.project_name}-subnet"
    project = var.project_name
  }
}

# Internet Gateway — without this, the subnet has zero outbound internet (AWS default)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    project = var.project_name
  }
}

# Route table — sends all non-local traffic (0.0.0.0/0) out through the IGW
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-rt"
    project = var.project_name
  }
}

# Associate the route table with the subnet — activates the routing rules above
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
