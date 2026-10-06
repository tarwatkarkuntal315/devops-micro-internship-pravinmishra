# Book Review App - Phase 4 database module
#
# Builds the managed MySQL layer described in docs/architecture-diagram.html:
#
#   App tier (:3306, db-sg) -> RDS MySQL primary (Multi-AZ) -> read replica
#
# Both instances live in the private DB-tier subnets only (db_subnet_ids),
# accept traffic solely from db_sg_id (App-tier security group, see the
# security module), and have publicly_accessible = false.
#
# Master password: generated here with random_password and stored in a
# Secrets Manager secret ({"username","password"}) that the App tier reads
# at boot via its IAM role. It is never in code, user data, or outputs; it
# IS in the local (git-ignored) terraform.tfstate.
#
# Why not manage_master_user_password = true (the original design)? First
# apply failed with "Creating read replicas for source instance with engine
# mysql where ManageMasterUserPassword is enabled is not supported" - RDS
# for MySQL cannot create a read replica from a source whose password is
# RDS-managed, and the read replica is a hard requirement.

resource "random_password" "db_master" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?" # RDS forbids / @ " and space
}

resource "aws_secretsmanager_secret" "db_master" {
  name        = "${var.name_prefix}/db-master"
  description = "Master credentials for the ${var.name_prefix} RDS MySQL primary (read by the App tier at boot)."

  # Lab stack is destroyed after every test session; delete immediately so
  # the same secret name can be recreated on the next apply.
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-master"
  })
}

resource "aws_secretsmanager_secret_version" "db_master" {
  secret_id = aws_secretsmanager_secret.db_master.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.db_master.result
  })
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-db-subnet-group"
  description = "Database-tier subnets (DB A / DB B) for the MySQL primary and read replica."
  subnet_ids  = var.db_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-group"
  })
}

# --- Primary instance -----------------------------------------------------
#
# multi_az = true gives a synchronously-replicated standby in the second DB
# subnet's AZ, promoted automatically on primary failure. AWS manages the
# standby's placement; availability_zone is intentionally left unset here,
# since the AWS API rejects an explicit availability_zone when multi_az is
# true (the primary floats across both DB subnets by design).

resource "aws_db_instance" "primary" {
  identifier = "${var.name_prefix}-mysql"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true

  db_name  = var.db_name
  username = var.username
  password = random_password.db_master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]
  multi_az               = true
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = false

  delete_automated_backups   = true
  apply_immediately          = true
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-mysql"
  })
}

# --- Read replica -----------------------------------------------------
#
# replicate_source_db uses the primary's identifier (not its ARN): per the
# aws_db_instance documentation, the identifier form is valid for a
# same-region replica as long as db_subnet_group_name is NOT also set on the
# replica - which is the case here, so it defaults to the primary's own
# subnet group (spanning both DB subnets) and is then pinned to
# ap-south-1b via availability_zone. db_name, username, and the managed
# password are all inherited from the source and must not be repeated here
# (the provider rejects db_name/username on a replica). multi_az is
# deliberately omitted (defaults to false) - the replica itself is single-AZ,
# only the primary gets a synchronous standby.

resource "aws_db_instance" "replica" {
  identifier          = "${var.name_prefix}-mysql-replica"
  replicate_source_db = aws_db_instance.primary.identifier

  instance_class    = var.instance_class
  availability_zone = var.replica_availability_zone
  storage_encrypted = true

  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false

  skip_final_snapshot        = true
  delete_automated_backups   = true
  apply_immediately          = true
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-mysql-replica"
  })
}
