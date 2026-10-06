variable "name_prefix" {
  description = "Short name prefix used for resource Name tags (e.g. \"book-review\")."
  type        = string
}

variable "db_subnet_ids" {
  description = "IDs of the private Database-tier subnets (DB A / DB B). The DB subnet group spans these so the primary and replica can be placed in either AZ."
  type        = list(string)
}

variable "db_sg_id" {
  description = "ID of the Database-tier security group (MySQL :3306 from the Application tier only, no internet exposure)."
  type        = string
}

variable "engine_version" {
  description = "MySQL engine version (major or major.minor prefix, e.g. \"8.0\"). With auto_minor_version_upgrade enabled, AWS resolves this to the current supported minor release in the region (verified via `aws rds describe-db-engine-versions` in ap-south-1: resolves to 8.0.46 at the time this module was written)."
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class for both the primary and the read replica. db.t3.micro was confirmed Multi-AZ-capable for MySQL on gp3 storage in ap-south-1 via `aws rds describe-orderable-db-instance-options`."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage, in GiB, for the primary instance."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "EBS storage type for the primary instance."
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Initial database name created on the primary instance. Must match the backend's DB_NAME environment variable - the application does not create its own database, only tables (sync({ alter: true }))."
  type        = string
  default     = "bookreview"
}

variable "username" {
  description = "Master username for the primary instance. The password is never supplied here - manage_master_user_password delegates it to an RDS-managed Secrets Manager secret."
  type        = string
  default     = "bookadmin"
}

variable "backup_retention_period" {
  description = "Days to retain automated backups on the primary instance. Must be greater than 0 for the instance to be usable as a read-replica source."
  type        = number
  default     = 1
}

variable "replica_availability_zone" {
  description = "Availability zone for the read replica. Kept in the opposite AZ from the Multi-AZ primary's usual standby placement for an extra layer of spread. The replica itself is single-AZ (no standby) - Multi-AZ is only applied to the primary for cost reasons."
  type        = string
  default     = "ap-south-1b"
}

variable "tags" {
  description = "Extra tags merged into every resource's Name tag block. Project/owner/managed_by tags are normally supplied via the provider's default_tags and do not need to be repeated here."
  type        = map(string)
  default     = {}
}
