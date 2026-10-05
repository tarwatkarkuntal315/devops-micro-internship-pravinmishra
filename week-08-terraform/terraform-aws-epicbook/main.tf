# Author: Kuntal Tarwatkar

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidr      = var.public_subnet_cidr
  private_db_subnet_cidrs = var.private_db_subnet_cidrs
  availability_zones      = var.availability_zones
  ssh_allowed_cidrs       = var.ssh_allowed_cidrs
}

module "ec2" {
  source = "./modules/ec2"

  project_name    = var.project_name
  instance_type   = var.instance_type
  key_name        = var.key_name
  public_key_path = var.public_key_path

  # Values passed from the network module
  public_subnet_id      = module.network.public_subnet_id
  ec2_security_group_id = module.network.ec2_security_group_id
}

module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  db_instance_class = var.db_instance_class
  engine_version    = var.db_engine_version
  allocated_storage = var.db_allocated_storage
  db_username       = var.db_username
  db_password       = var.db_password

  # Values passed from the network module
  private_db_subnet_ids = module.network.private_db_subnet_ids
  rds_security_group_id = module.network.rds_security_group_id
}
