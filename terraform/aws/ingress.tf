# Create Ingress EC2 Instance
resource "aws_instance" "ingress" {
  tags = {
    Name = "cognit-ingress"
  }
  instance_type = var.ec2_instance_type
  ami           = data.aws_ssm_parameter.ubuntu.value
  root_block_device {
    volume_size = var.volume_size
  }
  subnet_id                   = aws_subnet.cognit.id
  key_name                    = var.ssh_key
  vpc_security_group_ids      = [aws_security_group.ingress.id]
  associate_public_ip_address = true
  source_dest_check = false # required for routing/masquerading
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_key_path)
    host        = self.public_dns
  }
}

# Security Group for Ingress
resource "aws_security_group" "ingress" {
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

  # Allow access to oned redirection for terraform-opennebula
  ingress {
    from_port   = 2633
    to_port     = 2633
    protocol    = "tcp"
    cidr_blocks = ["${var.local_machine_ip}/32"]
  }

  # Allow access to oneflow redirection for terraform-opennebula
  ingress {
    from_port   = 2474
    to_port     = 2474
    protocol    = "tcp"
    cidr_blocks = ["${var.local_machine_ip}/32"]
  }

  # Allow all traffic coming from cognit subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.cognit.cidr_block]
  }

  # Allow BGP traffic from everywhere
  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Web traffic from everywhere
  # Redirect for Sunstone, FireEdge and Provisioning Engine
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
