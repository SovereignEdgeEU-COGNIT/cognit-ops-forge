provider "aws" {
  region = var.region
}

# Setup VPC for Cognit Deployment
resource "aws_vpc" "opsforge" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "opsforge"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "opsforge" {
  vpc_id = aws_vpc.opsforge.id

  tags = {
    Name = "opsforge"
  }
}

# Create Route Table
resource "aws_route_table" "opsforge" {
  vpc_id = aws_vpc.opsforge.id

  tags = {
    Name = "opsforge"
  }
}

# Create Route for Internet Traffic
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.opsforge.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.opsforge.id
}

# Setup Subnet for EC2 Instances
resource "aws_subnet" "cognit" {
  vpc_id     = aws_vpc.opsforge.id
  cidr_block = "10.0.1.0/24"
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "opsforge" {
  subnet_id      = aws_subnet.cognit.id
  route_table_id = aws_route_table.opsforge.id
}

# Retrieve Ubuntu 22.04 LTS AMI
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}













