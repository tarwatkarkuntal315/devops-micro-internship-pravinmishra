# Author: Kuntal Tarwatkar

variable "project_name" {
  description = "Prefix used for resource names"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private DB subnet IDs from the network module"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS security group ID from the network module"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
