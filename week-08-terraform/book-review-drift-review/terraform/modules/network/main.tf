# Book Review App - Phase 1 networking module
#
# Builds the VPC, 6 subnets (2 web / 2 app / 2 db across two AZs), one
# Internet Gateway, one NAT Gateway, and the three route tables + their
# subnet associations described in docs/architecture-diagram.html.
#
# No security groups, load balancers, compute, or database resources are
# created here - those are later phases.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.tier == "web"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}"
    Tier = each.value.tier
  })
}

locals {
  web_subnet_ids = [for k, s in aws_subnet.this : s.id if var.subnets[k].tier == "web"]
  app_subnet_ids = [for k, s in aws_subnet.this : s.id if var.subnets[k].tier == "app"]
  db_subnet_ids  = [for k, s in aws_subnet.this : s.id if var.subnets[k].tier == "db"]
}

# --- NAT Gateway -------------------------------------------------------
#
# DELIBERATE COST-CONSCIOUS LAB CHOICE: a single NAT Gateway (placed in
# var.nat_gateway_subnet_key, default "web_a") serves outbound egress for
# BOTH App-tier subnets, instead of one NAT Gateway per AZ.
#
# DOCUMENTED SINGLE POINT OF FAILURE: if the AZ hosting this NAT Gateway
# becomes unavailable, App-tier instances in the other AZ lose outbound
# internet access (e.g. OS package updates) until it is restored or a
# second NAT Gateway is added. This does not affect inbound traffic from
# the internal ALB, since that traffic never leaves the VPC.

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.this[var.nat_gateway_subnet_key].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw"
  })

  depends_on = [aws_internet_gateway.this]
}

# --- Route tables -------------------------------------------------------

# Public RT: Web subnets -> Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-public"
  })
}

# Private App RT: App subnets -> NAT Gateway
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-app"
  })
}

# Private DB RT: no route block - local-only traffic within the VPC,
# no path to the internet under any circumstances.
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-db"
  })
}

# --- Route table associations --------------------------------------------

resource "aws_route_table_association" "web" {
  for_each = { for k, v in var.subnets : k => v if v.tier == "web" }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  for_each = { for k, v in var.subnets : k => v if v.tier == "app" }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db" {
  for_each = { for k, v in var.subnets : k => v if v.tier == "db" }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.db.id
}
