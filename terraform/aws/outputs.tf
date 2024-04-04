output "cloud" {
  value = aws_instance.cloud.public_dns
  description = "Cloud-Edge Manager public domain name"
}

output "engine" {
  value = aws_instance.engine.public_dns
  description = "Provision Engine public domain name"
}

output "ai_orchestrator" {
  value = aws_instance.ai.public_dns
  description = "Provision Engine public domain name"
}
