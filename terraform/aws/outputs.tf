output "ingress" {
  value = {
    "public_dns" : aws_instance.ingress.public_dns,
    "private_ip" : aws_instance.ingress.private_ip
  }
}
output "cloud" {
  value = {
    "public_dns" : aws_instance.cloud.public_dns,
    "private_ip" : aws_instance.cloud.private_ip
  }
}

output "frontend" {
  value = {
    "public_dns" : aws_instance.frontend.public_dns,
    "private_ip" : aws_instance.frontend.private_ip
  }
}

output "ai_orchestrator" {
  value = {
    "public_dns" : aws_instance.ai.public_dns,
    "private_ip" : aws_instance.ai.private_ip
  }
}
