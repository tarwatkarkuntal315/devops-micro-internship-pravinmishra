module "network" {
  source = "./modules/network"

  name_prefix = var.project
  vpc_cidr    = var.vpc_cidr
  subnets     = var.subnets
}

module "security" {
  source = "./modules/security"

  name_prefix = var.project
  vpc_id      = module.network.vpc_id
  admin_cidr  = var.admin_cidr
}

module "alb" {
  source = "./modules/alb"

  name_prefix        = var.project
  vpc_id             = module.network.vpc_id
  web_subnet_ids     = module.network.web_subnet_ids
  app_subnet_ids     = module.network.app_subnet_ids
  public_alb_sg_id   = module.security.public_alb_sg_id
  internal_alb_sg_id = module.security.internal_alb_sg_id
}

module "database" {
  source = "./modules/database"

  name_prefix   = var.project
  db_subnet_ids = module.network.db_subnet_ids
  db_sg_id      = module.security.db_sg_id
}

module "compute" {
  source = "./modules/compute"

  name_prefix = var.project
  region      = var.region

  web_subnet_ids = module.network.web_subnet_ids
  app_subnet_ids = module.network.app_subnet_ids

  web_sg_id = module.security.web_sg_id
  app_sg_id = module.security.app_sg_id

  web_tg_arn = module.alb.web_tg_arn
  app_tg_arn = module.alb.app_tg_arn

  public_alb_dns_name   = module.alb.public_alb_dns_name
  internal_alb_dns_name = module.alb.internal_alb_dns_name

  db_endpoint_address    = module.database.db_endpoint_address
  db_port                = module.database.db_port
  db_name                = module.database.db_name
  db_username            = module.database.db_username
  master_user_secret_arn = module.database.master_user_secret_arn

  web_instance_type   = var.web_instance_type
  app_instance_type   = var.app_instance_type
  repo_url            = var.repo_url
  jwt_secret          = var.jwt_secret
  ssh_public_key_path = var.ssh_public_key_path
}
