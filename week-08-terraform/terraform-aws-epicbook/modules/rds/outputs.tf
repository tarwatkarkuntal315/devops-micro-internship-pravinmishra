# Author: Kuntal Tarwatkar

output "rds_endpoint" {
  description = "RDS hostname (without port)"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}
