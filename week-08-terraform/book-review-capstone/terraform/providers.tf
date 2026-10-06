provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project    = var.project
      owner      = var.owner
      managed_by = "terraform"
    }
  }
}
