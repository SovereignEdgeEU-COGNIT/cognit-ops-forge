# Create Engine EC2 Instance
resource "aws_instance" "engine" {
  tags = {
    Name = "cognit-provision_engine"
  }
  instance_type = var.ec2_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.ssh_key
  vpc_security_group_ids      = [aws_security_group.engine.id]
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_key_path)
    host        = self.public_dns
  }
}

# Security Group for Provision Engine
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

  # Allow engine traffic from the COGNIT subnet only
  ingress {
    from_port   = var.engine_port
    to_port     = var.engine_port
    protocol    = "tcp"
    cidr_blocks = [ aws_subnet.cognit.cidr_block ]
  }

}
