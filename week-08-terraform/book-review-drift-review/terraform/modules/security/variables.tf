variable "name_prefix" {
  description = "Short name prefix used for resource Name tags (e.g. \"book-review\")."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that the security groups belong to."
  type        = string
}

variable "admin_cidr" {
  description = "Single admin workstation address, as a /32 CIDR (e.g. \"203.0.113.10/32\"), allowed to SSH into the Web tier. Supply via -var or a git-ignored terraform.tfvars; this value has no default and changes whenever the student's IP changes."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.admin_cidr))
    error_message = "admin_cidr must be a single-host IPv4 CIDR in the form \"a.b.c.d/32\"."
  }
}

variable "tags" {
  description = "Extra tags merged into every resource's Name tag block. Project/owner/managed_by tags are normally supplied via the provider's default_tags and do not need to be repeated here."
  type        = map(string)
  default     = {}
}
