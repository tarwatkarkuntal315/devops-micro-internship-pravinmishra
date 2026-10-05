# Author: Kuntal Tarwatkar

variable "project_name" {
  description = "Prefix used for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (EC2)"
  type        = string
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for the two private DB subnets (A, B)"
  type        = list(string)
}

variable "availability_zones" {
  description = "Two different AZs for DB subnet A and B; the first is also used by the public subnet"
  type        = list(string)
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into EC2"
  type        = list(string)
}
