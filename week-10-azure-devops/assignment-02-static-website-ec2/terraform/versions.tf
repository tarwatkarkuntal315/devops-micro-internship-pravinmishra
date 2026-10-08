terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Owner     = "Kuntal Tarwatkar"
      ManagedBy = "Terraform"
      Purpose   = "DMI Week 10 Assignment 02"
    }
  }
}
