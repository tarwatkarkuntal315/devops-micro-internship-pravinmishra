variable "name_prefix" {
  description = "Short name prefix used for resource Name tags (e.g. \"book-review\")."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "subnets" {
  description = "Map of subnets keyed by logical name (e.g. web_a, app_b, db_a). Each value defines the CIDR block, availability zone, and tier (web/app/db)."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tier              = string
  }))

  validation {
    condition     = alltrue([for s in var.subnets : contains(["web", "app", "db"], s.tier)])
    error_message = "Each subnet's \"tier\" must be one of \"web\", \"app\", or \"db\"."
  }
}

variable "nat_gateway_subnet_key" {
  description = "Key (from var.subnets) of the subnet that hosts the single NAT Gateway. Must reference a \"web\" tier subnet."
  type        = string
  default     = "web_a"

  validation {
    condition     = try(var.subnets[var.nat_gateway_subnet_key].tier == "web", false)
    error_message = "nat_gateway_subnet_key must be a key in var.subnets whose tier is \"web\" (the NAT Gateway needs a public subnet)."
  }
}

variable "tags" {
  description = "Extra tags merged into every resource's Name tag block. Project/owner/managed_by tags are normally supplied via the provider's default_tags and do not need to be repeated here."
  type        = map(string)
  default     = {}
}
