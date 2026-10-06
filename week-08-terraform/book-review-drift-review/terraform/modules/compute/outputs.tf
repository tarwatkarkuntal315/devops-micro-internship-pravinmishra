output "web_instance_ids" {
  description = "IDs of the Web-tier EC2 instances, keyed by AZ (a/b)."
  value       = { for k, v in aws_instance.web : k => v.id }
}

output "web_public_ips" {
  description = "Public IPv4 addresses of the Web-tier EC2 instances, keyed by AZ (a/b). For SSH/verification only - not a secret."
  value       = { for k, v in aws_instance.web : k => v.public_ip }
}

output "app_instance_ids" {
  description = "IDs of the Application-tier EC2 instances, keyed by AZ (a/b)."
  value       = { for k, v in aws_instance.app : k => v.id }
}

output "app_private_ips" {
  description = "Private IPv4 addresses of the Application-tier EC2 instances, keyed by AZ (a/b). For SSH bastion hop / SSM verification only - not a secret."
  value       = { for k, v in aws_instance.app : k => v.private_ip }
}

output "jwt_ssm_parameter_name" {
  description = "Name (not value) of the SSM SecureString parameter holding JWT_SECRET. Useful for verifying App-tier IAM access; never resolve its value through Terraform."
  value       = aws_ssm_parameter.jwt_secret.name
}

output "web_role_arn" {
  description = "ARN of the Web-tier IAM role. Not a secret - useful for verification (e.g. confirming SSM Session Manager access)."
  value       = aws_iam_role.web.arn
}

output "app_role_arn" {
  description = "ARN of the Application-tier IAM role. Not a secret - useful for verification of the scoped Secrets Manager/SSM permissions."
  value       = aws_iam_role.app.arn
}
