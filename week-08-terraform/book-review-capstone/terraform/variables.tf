variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1"
}

variable "azs" {
  description = "Availability zones used for this deployment. Documented here for reference by later phases (compute, database); the network module itself derives AZ placement from var.subnets."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "project" {
  description = "Project name used for tagging and resource name prefixes."
  type        = string
  default     = "book-review"
}

variable "owner" {
  description = "Owner tag applied to all resources."
  type        = string
  default     = "Kuntal Tarwatkar"
}

variable "admin_cidr" {
  description = "Single admin workstation address, as a /32 CIDR (e.g. \"203.0.113.10/32\"), allowed to SSH into the Web tier. No default - supply via -var or a git-ignored terraform.tfvars. This value changes whenever the student's IP changes; find the current one with `curl -s https://checkip.amazonaws.com`."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.admin_cidr))
    error_message = "admin_cidr must be a single-host IPv4 CIDR in the form \"a.b.c.d/32\"."
  }
}

variable "subnets" {
  description = "Map of subnets keyed by logical name (e.g. web_a, app_b, db_a). Each value defines the CIDR block, availability zone, and tier (web/app/db)."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tier              = string
  }))

  default = {
    web_a = { cidr_block = "10.0.1.0/24", availability_zone = "ap-south-1a", tier = "web" }
    web_b = { cidr_block = "10.0.2.0/24", availability_zone = "ap-south-1b", tier = "web" }
    app_a = { cidr_block = "10.0.11.0/24", availability_zone = "ap-south-1a", tier = "app" }
    app_b = { cidr_block = "10.0.12.0/24", availability_zone = "ap-south-1b", tier = "app" }
    db_a  = { cidr_block = "10.0.21.0/24", availability_zone = "ap-south-1a", tier = "db" }
    db_b  = { cidr_block = "10.0.22.0/24", availability_zone = "ap-south-1b", tier = "db" }
  }

  validation {
    condition     = alltrue([for s in var.subnets : contains(["web", "app", "db"], s.tier)])
    error_message = "Each subnet's \"tier\" must be one of \"web\", \"app\", or \"db\"."
  }
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

variable "repo_url" {
  description = "Git URL of the Book Review App monorepo (frontend/ + backend/), cloned onto both tiers at boot."
  type        = string
  default     = "https://github.com/pravinmishraaws/book-review-app.git"
}

variable "jwt_secret" {
  description = "Value for the backend's JWT_SECRET environment variable. No default - generate with `openssl rand -hex 32` and supply via -var, TF_VAR_jwt_secret, or a git-ignored terraform.tfvars. Stored only as an SSM SecureString parameter that App-tier instances read at boot over their IAM role; never emitted in a Terraform output."
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
