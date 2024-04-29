# Create AI Orchestrator EC2 Instance
resource "aws_instance" "ai" {
  tags = {
    Name = "cognit-ai_orchestrator"
  }
  instance_type = var.ec2_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.ssh_key
  vpc_security_group_ids      = [aws_security_group.ai.id]
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_key_path)
    host        = self.public_dns
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

  # Allow external scheduler traffic on the cognit subnet
  ingress {
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.cognit.cidr_block]
  }
}
