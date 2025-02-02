output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_lb.dns_name
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "blue_tg_arn" {
  value = aws_lb_target_group.blue.arn
}

output "pink_tg_arn" {
  value = aws_lb_target_group.pink.arn
}

output "lime_tg_arn" {
  value = aws_lb_target_group.lime.arn
}