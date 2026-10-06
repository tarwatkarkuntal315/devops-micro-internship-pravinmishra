output "public_alb_sg_id" {
  description = "ID of the public-facing ALB security group (internet HTTP :80 only)."
  value       = aws_security_group.public_alb.id
}

output "web_sg_id" {
  description = "ID of the Web-tier security group."
  value       = aws_security_group.web.id
}

output "internal_alb_sg_id" {
  description = "ID of the internal ALB security group (reachable from the Web tier only)."
  value       = aws_security_group.internal_alb.id
}

output "app_sg_id" {
  description = "ID of the Application-tier security group."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the Database-tier security group (reachable from the Application tier only)."
  value       = aws_security_group.db.id
}
