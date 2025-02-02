output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_lb.dns_name
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

