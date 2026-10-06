output "db_endpoint_address" {
  description = "Hostname of the primary RDS instance (no port - see db_port). This is what the backend's DB_HOST environment variable should be set to."
  value       = aws_db_instance.primary.address
}

output "db_port" {
  description = "Port the primary RDS instance accepts MySQL connections on."
  value       = aws_db_instance.primary.port
}

output "db_name" {
  description = "Database name created on the primary instance. Not a secret - needed for the backend's DB_NAME environment variable."
  value       = aws_db_instance.primary.db_name
}

output "db_username" {
  description = "Master username for the primary instance. Not a secret by itself (the password lives in Secrets Manager, see master_user_secret_arn) - needed for the backend's DB_USER environment variable."
  value       = aws_db_instance.primary.username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master credentials ({\"username\",\"password\"}). Never the password itself - compute fetches the secret value at instance boot via its IAM role."
  value       = aws_secretsmanager_secret.db_master.arn
}

output "replica_endpoint_address" {
  description = "Hostname of the read replica, for read-only workloads that choose to use it. Not required by the current backend, which only has a single DB_HOST."
  value       = aws_db_instance.replica.address
}

output "primary_identifier" {
  description = "Identifier of the primary RDS instance (e.g. for aws rds describe-db-instances during verification)."
  value       = aws_db_instance.primary.identifier
}
