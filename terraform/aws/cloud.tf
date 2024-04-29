# Create Cloud-Edge Manager EC2 Instance
resource "aws_instance" "cloud" {
  tags = {
    Name = "cognit-cloud"
  }
  instance_type = var.ec2_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.ssh_key
  vpc_security_group_ids      = [aws_security_group.cloud.id]
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_key_path)
    host        = self.public_dns
  }
}

# Security Group for cloud
resource "aws_security_group" "cloud" {
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

  # Allow sunstone_port from the cognit subnet
  ingress {
    from_port   = var.sunstone_port
    to_port     = var.sunstone_port
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.cognit.cidr_block]
  }

  # Allow fireedge_port from the cognit subnet
  ingress {
    from_port   = var.fireedge_port
    to_port     = var.fireedge_port
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.cognit.cidr_block]
  }

  # Allow access to oned and oneflow
  ingress {
    from_port   = 2633
    to_port     = 2633
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.cognit.cidr_block, "${var.local_machine_ip}/32"]
  }

  ingress {
    from_port   = 2474
    to_port     = 2474
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.cognit.cidr_block, "${var.local_machine_ip}/32"]
  }
}
