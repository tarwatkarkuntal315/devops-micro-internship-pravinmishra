# Author: Kuntal Tarwatkar

variable "project_name" {
  description = "Prefix used for resource names"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID from the network module"
  type        = string
}

variable "ec2_security_group_id" {
  description = "EC2 security group ID from the network module"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "public_key_path" {
  description = "Path to the local SSH public key"
  type        = string
}
