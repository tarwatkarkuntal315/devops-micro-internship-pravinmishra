output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "IPv4 CIDR block of the VPC."
  value       = module.network.vpc_cidr
}

output "web_subnet_ids" {
  description = "IDs of the public Web-tier subnets."
  value       = module.network.web_subnet_ids
}

output "app_subnet_ids" {
  description = "IDs of the private Application-tier subnets."
  value       = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  description = "IDs of the private Database-tier subnets."
  value       = module.network.db_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the single NAT Gateway (documented single point of failure for App-tier egress if its AZ is unavailable)."
  value       = module.network.nat_gateway_id
}

output "public_alb_dns_name" {
  description = "DNS name of the internet-facing ALB - the application's public URL, and the value to bake into NEXT_PUBLIC_API_URL at frontend build time."
  value       = module.alb.public_alb_dns_name
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB. Not a secret - an AWS-internal DNS name needed by the Web-tier Nginx /api proxy configuration."
  value       = module.alb.internal_alb_dns_name
}

output "db_endpoint_address" {
  description = "Hostname of the primary RDS MySQL instance (no port). Needed for the backend's DB_HOST environment variable and for verification/screenshots."
  value       = module.database.db_endpoint_address
}

output "db_replica_endpoint_address" {
  description = "Hostname of the RDS MySQL read replica. Not consumed by the current backend (single DB_HOST), but useful for verification/screenshots that the replica exists and is reachable."
  value       = module.database.replica_endpoint_address
}

output "app_url" {
  description = "Public application URL (browser entry point): public ALB -> Web-tier Nginx -> Next.js."
  value       = "http://${module.alb.public_alb_dns_name}"
}

output "web_public_ips" {
  description = "Public IPv4 addresses of the Web-tier EC2 instances, keyed by AZ (a/b). For SSH/verification only - not a secret."
  value       = module.compute.web_public_ips
}

output "app_private_ips" {
  description = "Private IPv4 addresses of the Application-tier EC2 instances, keyed by AZ (a/b). For SSH bastion hop / SSM verification only - not a secret."
  value       = module.compute.app_private_ips
}
