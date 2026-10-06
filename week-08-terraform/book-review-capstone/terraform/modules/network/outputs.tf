output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "IPv4 CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "web_subnet_ids" {
  description = "IDs of the public Web-tier subnets."
  value       = local.web_subnet_ids
}

output "app_subnet_ids" {
  description = "IDs of the private Application-tier subnets."
  value       = local.app_subnet_ids
}

output "db_subnet_ids" {
  description = "IDs of the private Database-tier subnets."
  value       = local.db_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the single NAT Gateway. Documented single point of failure: if the AZ hosting it is unavailable, App-tier subnets lose outbound internet access until it is restored or a second NAT Gateway is added."
  value       = aws_nat_gateway.this.id
}
