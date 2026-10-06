variable "name_prefix" {
  description = "Short name prefix used for resource Name tags (e.g. \"book-review\")."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that the target groups belong to."
  type        = string
}

variable "web_subnet_ids" {
  description = "IDs of the public Web-tier subnets. The public ALB is placed here."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "IDs of the private Application-tier subnets. The internal ALB is placed here."
  type        = list(string)
}

variable "public_alb_sg_id" {
  description = "ID of the public ALB security group (internet HTTP :80 in, forwards to Web tier)."
  type        = string
}

variable "internal_alb_sg_id" {
  description = "ID of the internal ALB security group (HTTP from Web tier only, forwards to App tier :3001)."
  type        = string
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks before a target is considered healthy."
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks before a target is considered unhealthy."
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Approximate time, in seconds, between health checks of an individual target."
  type        = number
  default     = 15
}

variable "health_check_timeout" {
  description = "Time, in seconds, to wait for a health check response before failing it."
  type        = number
  default     = 5
}

variable "health_check_path" {
  description = "Path used for HTTP health checks on both target groups."
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP status code(s) considered a successful health check response."
  type        = string
  default     = "200"
}

variable "deregistration_delay" {
  description = "Seconds to wait before a deregistering target moves from draining to unused. Kept short for a lab so destroy/recreate cycles don't stall."
  type        = number
  default     = 30
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on both ALBs. Must stay false in this lab so terraform destroy can tear the stack down."
  type        = bool
  default     = false
}

variable "drop_invalid_header_fields" {
  description = "Whether both ALBs strip HTTP headers with invalid field names instead of forwarding them to targets."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags merged into every resource's Name tag block. Project/owner/managed_by tags are normally supplied via the provider's default_tags and do not need to be repeated here."
  type        = map(string)
  default     = {}
}
