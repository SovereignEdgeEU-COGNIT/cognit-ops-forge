provider "aws" {
  region = var.aws_region
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

# Create Frontend EC2 Instance
resource "aws_instance" "frontend" {
  tags = {
    Name = "cognit-frontend"
  }
  instance_type = var.aws_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.aws_volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.aws_ssh_key
  vpc_security_group_ids      = [aws_security_group.frontend.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.aws_ssh_key_path)
    host        = self.public_dns
  }
}


# Create Engine EC2 Instance
resource "aws_instance" "engine" {
  tags = {
    Name = "cognit-provision_engine"
  }
  instance_type = var.aws_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.aws_volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.aws_ssh_key
  vpc_security_group_ids      = [aws_security_group.engine.id]
  associate_public_ip_address = true
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.aws_ssh_key_path)
    host        = self.public_dns
  }
}

# Create Engine EC2 Instance
resource "aws_instance" "ai" {
  tags = {
    Name = "cognit-ai_orchestrator"
  }
  instance_type = var.aws_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.aws_volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.aws_ssh_key
  vpc_security_group_ids      = [aws_security_group.ai.id]
  associate_public_ip_address = true
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.aws_ssh_key_path)
    host        = self.public_dns
  }
}

# Security Group for Frontend
resource "aws_security_group" "frontend" {
  vpc_id = aws_vpc.opsforge.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow one_sunstone_port from anywhere
  ingress {
    from_port   = var.one_sunstone_port
    to_port     = var.one_sunstone_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow one_fireedge_port from anywhere
  ingress {
    from_port   = var.one_fireedge_port
    to_port     = var.one_fireedge_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow access to oned from your local machine
  ingress {
    from_port   = 2633
    to_port     = 2633
    protocol    = "tcp"
    cidr_blocks = ["${var.local_machine_ip}/32"]
  }

  # Allow access to oneflow from your local machine
  ingress {
    from_port   = 2474
    to_port     = 2474
    protocol    = "tcp"
    cidr_blocks = ["${var.local_machine_ip}/32"]
  }
}

# Security Group for Engine
resource "aws_security_group" "engine" {
  vpc_id = aws_vpc.opsforge.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Provision Engine access from anywhere
  ingress {
    from_port   = var.cognit_engine_port
    to_port     = var.cognit_engine_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for AI Orchestrator
resource "aws_security_group" "ai" {
  vpc_id = aws_vpc.opsforge.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group Rule for Engine to Frontend (oned)
resource "aws_security_group_rule" "engine_to_frontend_oned" {
  type              = "ingress"
  from_port         = 2633
  to_port           = 2633
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend.id
  cidr_blocks       = [aws_subnet.cognit.cidr_block] # Allow from the cognit subnet
}

# Security Group Rule for Engine to Frontend (oneflow)
resource "aws_security_group_rule" "engine_to_frontend_oneflow" {
  type              = "ingress"
  from_port         = 2474
  to_port           = 2474
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend.id
  cidr_blocks       = [aws_subnet.cognit.cidr_block] # Allow from the cognit subnet
}

# Security Group Rule for AI-Orchestrator to Frontend
resource "aws_security_group_rule" "external_scheduler" {
  type              = "ingress"
  from_port         = 4567
  to_port           = 4567
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend.id
  cidr_blocks       = [aws_subnet.cognit.cidr_block] # Allow from the cognit subnet
}
