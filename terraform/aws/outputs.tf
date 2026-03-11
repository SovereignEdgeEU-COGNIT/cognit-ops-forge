output "frontend" {
  value = {
    public_dns = aws_instance.frontend.public_dns
    private_ip = aws_instance.frontend.private_ip
  }
}
