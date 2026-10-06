# Book Review App - Phase 5 compute module
#
# Builds the Web-tier and Application-tier EC2 instances described in
# docs/architecture-diagram.html, their IAM roles/instance profiles
# (iam.tf), the shared SSH key pair, and the JWT secret SSM parameter.
# Target-group attachments live in web.tf/app.tf next to the instances
# they attach, because they need instance IDs that only this module
# creates - see modules/alb/main.tf's header comment for why that split
# avoids a dependency cycle between alb and compute.
#
# AMI: Amazon Linux 2023 (x86_64), resolved via the official public SSM
# parameter rather than an aws_ami data source filter, so the AMI always
# tracks the latest AL2023 release without an owner/name filter that could
# silently match an unexpected image.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# --- SSH key pair -----------------------------------------------------
#
# Both tiers use the SAME key pair. Web instances are reachable directly
# over SSH from the admin IP (see security module); App instances have no
# public IP and are reached only by hopping through a Web instance or via
# SSM Session Manager - never directly from the internet. Only the PUBLIC
# key ever touches Terraform or AWS; the private key stays on the admin's
# workstation and is never read, templated, or committed.

resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-key"
  })
}

# --- JWT secret ---------------------------------------------------------
#
# Stored as a SecureString SSM parameter (default AWS-managed "aws/ssm"
# KMS key). App-tier instances fetch its VALUE at boot via `aws ssm
# get-parameter --with-decryption`, authenticated by their IAM role - only
# the parameter's NAME/ARN is passed through Terraform resources/outputs.
# var.jwt_secret is necessarily present in this resource's Terraform state
# (there is no way to create an SSM SecureString without Terraform
# supplying its value) - the control that matters, and that this module
# upholds, is that the value is never emitted in a root/module OUTPUT or
# written into instance user data.

resource "aws_ssm_parameter" "jwt_secret" {
  name        = "/${var.name_prefix}/jwt-secret"
  description = "Backend JWT_SECRET. Written by Terraform from a sensitive variable; read by App-tier instances at boot via their IAM role. Never exposed in a Terraform output."
  type        = "SecureString"
  value       = var.jwt_secret

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-jwt-secret"
  })
}

locals {
  # Build {a = <subnet 0>, b = <subnet 1>} maps for for_each over instances.
  # See the web_subnet_ids/app_subnet_ids variable descriptions for why
  # index 0/1 reliably correspond to AZ "a"/"b".
  web_subnets = { a = var.web_subnet_ids[0], b = var.web_subnet_ids[1] }
  app_subnets = { a = var.app_subnet_ids[0], b = var.app_subnet_ids[1] }

  # Browser-facing URL built once and reused for both the frontend build
  # arg and the backend's CORS allow-list. Lower-cased because the
  # backend's ALLOWED_ORIGINS check compares case-sensitively against the
  # browser's Origin header; ALB DNS names are already lowercase, this is
  # a defensive normalization in case that ever changes.
  public_alb_url      = "http://${lower(var.public_alb_dns_name)}"
  next_public_api_url = "${local.public_alb_url}/api"
}
