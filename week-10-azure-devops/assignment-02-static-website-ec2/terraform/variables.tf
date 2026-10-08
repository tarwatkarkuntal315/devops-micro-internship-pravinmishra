variable "aws_region" {
  description = "AWS region for the target EC2 instance"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "azure-static-website"
}

variable "instance_type" {
  description = "EC2 instance type (free-tier eligible in ap-south-1 for this account)"
  type        = string
  default     = "t3.micro"
}

variable "admin_public_key_path" {
  description = "Path to the public key used for the 'ubuntu' admin user (Ansible connects with this key)"
  type        = string
  default     = "~/.ssh/dmi-ec2-admin.pub"
}

variable "ssh_allowed_cidrs" {
  description = "Source CIDRs allowed to reach TCP 22: my workstation and the Azure DevOps self-hosted agent VM"
  type        = map(string)
}
