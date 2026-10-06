variable "name_prefix" {
  description = "Short name prefix used for resource Name tags (e.g. \"book-review\")."
  type        = string
}

variable "region" {
  description = "AWS region to deploy into. Needed at boot time by the App-tier user data (aws secretsmanager / aws ssm CLI calls)."
  type        = string
}

variable "web_subnet_ids" {
  description = "IDs of the public Web-tier subnets (exactly 2, one per AZ). Index 0 is treated as AZ \"a\", index 1 as AZ \"b\" - safe because modules/network builds this list from subnet keys \"web_a\"/\"web_b\", and Terraform's for-expression iterates map keys in sorted order."
  type        = list(string)

  validation {
    condition     = length(var.web_subnet_ids) == 2
    error_message = "web_subnet_ids must contain exactly 2 subnet IDs (one per AZ)."
  }
}

variable "app_subnet_ids" {
  description = "IDs of the private Application-tier subnets (exactly 2, one per AZ). Same \"a\"/\"b\" index ordering assumption as web_subnet_ids."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_ids) == 2
    error_message = "app_subnet_ids must contain exactly 2 subnet IDs (one per AZ)."
  }
}

variable "web_sg_id" {
  description = "ID of the Web-tier security group (HTTP from public ALB, SSH from admin IP only)."
  type        = string
}

variable "app_sg_id" {
  description = "ID of the Application-tier security group (:3001 from internal ALB only, SSH bastion hop from Web tier)."
  type        = string
}

variable "web_tg_arn" {
  description = "ARN of the public ALB's Web-tier target group (port 80). Web instances are attached to it here."
  type        = string
}

variable "app_tg_arn" {
  description = "ARN of the internal ALB's Application-tier target group (port 3001). App instances are attached to it here."
  type        = string
}

variable "public_alb_dns_name" {
  description = "DNS name of the internet-facing ALB. Used to build NEXT_PUBLIC_API_URL (frontend build) and ALLOWED_ORIGINS (backend CORS), lower-cased, since the backend compares against the browser's Origin header case-sensitively."
  type        = string
}

variable "internal_alb_dns_name" {
  description = "DNS name of the internal ALB. Web-tier Nginx proxies /api/ to this host, re-resolving it periodically via the VPC resolver rather than caching its IP(s)."
  type        = string
}

variable "db_endpoint_address" {
  description = "Hostname of the primary RDS instance. Passed to the App tier as DB_HOST."
  type        = string
}

variable "db_port" {
  description = "Port the primary RDS instance accepts MySQL connections on. Passed to the App tier as DB_PORT."
  type        = number
}

variable "db_name" {
  description = "Database name on the primary RDS instance. Passed to the App tier as DB_NAME."
  type        = string
}

variable "db_username" {
  description = "Master username on the primary RDS instance. Passed to the App tier as DB_USER. The password is never passed through this variable - it is fetched at boot from Secrets Manager (see master_user_secret_arn)."
  type        = string
}

variable "master_user_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret holding the master password. App-tier instances fetch the password at boot via their IAM role; Terraform never reads the secret's value."
  type        = string
}

variable "repo_url" {
  description = "Git URL of the Book Review App monorepo (frontend/ + backend/), cloned onto both tiers at boot."
  type        = string
  default     = "https://github.com/pravinmishraaws/book-review-app.git"
}

variable "jwt_secret" {
  description = "Value for the backend's JWT_SECRET environment variable. No default - generate with `openssl rand -hex 32` and supply via -var, TF_VAR_jwt_secret, or a git-ignored terraform.tfvars. Written only to an SSM SecureString parameter that App-tier instances read at boot by name over their IAM role; never emitted in a Terraform output."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must be at least 32 characters long."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the PUBLIC half of the admin SSH key pair (e.g. \"~/.ssh/epicbook-key.pub\"), registered with AWS and used by both tiers. Only the public key is ever read - never point this at a private key."
  type        = string
  default     = "~/.ssh/epicbook-key.pub"
}

variable "web_instance_type" {
  description = "EC2 instance type for the Web tier. t3.small default: `npm run build` for Next.js needs more than the 1 GiB available on t3.micro; a 2 GiB swapfile is also created in user data as a cost-conscious safety margin."
  type        = string
  default     = "t3.small"
}

variable "app_instance_type" {
  description = "EC2 instance type for the Application tier. The Express backend is lightweight; t3.micro is sufficient."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root EBS volume size, in GiB, for both tiers' instances."
  type        = number
  default     = 20
}

variable "app_start_delay_seconds" {
  description = "Seconds the SECOND App-tier instance (AZ \"b\") sleeps before starting the backend, so two instances booting at nearly the same moment do not both run sequelize sync({alter:true}) + sample-data seeding against an empty database at once. A pragmatic lab mitigation, not a distributed lock - it shrinks the race window, it does not eliminate it."
  type        = number
  default     = 120
}

variable "tags" {
  description = "Extra tags merged into every resource's Name tag block. Project/owner/managed_by tags are normally supplied via the provider's default_tags and do not need to be repeated here."
  type        = map(string)
  default     = {}
}
