# Author: Kuntal Tarwatkar

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Prefix used for resource names"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_db_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "ssh_allowed_cidrs" {
  description = "Your public IP(s) in CIDR form for SSH"
  type        = list(string)
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
