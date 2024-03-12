output "ssh_connection_frontend" {
  value = "ssh -i ${var.aws_ssh_key_path} ${var.ssh_user}@${aws_instance.frontend.public_dns}"
}

output "ssh_connection_engine" {
  value = "ssh -i ${var.aws_ssh_key_path} ${var.ssh_user}@${aws_instance.engine.public_dns}"
}
