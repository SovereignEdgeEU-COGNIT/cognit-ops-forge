output "frontend" {
  value = aws_instance.frontend.public_dns
  description = "Frontend public domain name"
}

output "engine" {
  value = aws_instance.engine.public_dns
  description = "Provision Engine public domain name"
}

output "ai_orchestrator" {
  value = aws_instance.ai.public_dns
  description = "Provision Engine public domain name"
}
