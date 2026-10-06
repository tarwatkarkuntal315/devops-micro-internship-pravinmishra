output "public_alb_dns_name" {
  description = "DNS name of the internet-facing ALB. This is the application's public URL and the value to bake into NEXT_PUBLIC_API_URL at frontend build time."
  value       = aws_lb.public.dns_name
}

output "public_alb_arn" {
  description = "ARN of the internet-facing ALB."
  value       = aws_lb.public.arn
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB. Not a secret - an AWS-internal DNS name the Web-tier Nginx config needs for its /api proxy_pass target."
  value       = aws_lb.internal.dns_name
}

output "web_tg_arn" {
  description = "ARN of the Web-tier target group (port 80). Consumed by the compute module to register Web EC2 instances."
  value       = aws_lb_target_group.web.arn
}

output "app_tg_arn" {
  description = "ARN of the Application-tier target group (port 3001). Consumed by the compute module to register App EC2 instances."
  value       = aws_lb_target_group.app.arn
}
