# Book Review App - Phase 2 security module
#
# Builds the five chained security groups described in
# docs/architecture-diagram.html:
#
#   public-alb-sg -> web-sg -> internal-alb-sg -> app-sg -> db-sg
#
# All tier-to-tier rules reference security groups (referenced_security_group_id),
# never CIDR blocks, except the one internet-open rule on public-alb-sg and the
# admin SSH rule on web-sg. Rules are modeled as standalone
# aws_vpc_security_group_ingress_rule / aws_vpc_security_group_egress_rule
# resources (current AWS provider best practice) rather than inline
# ingress/egress blocks on aws_security_group, which struggle with per-rule
# descriptions, tags, and multiple sources.
#
# IMPORTANT: a new aws_security_group that only has standalone rule resources
# attached (no inline egress block) starts with ZERO egress - Terraform
# removes AWS's default allow-all egress rule on creation. Every security
# group below gets its egress rules added explicitly; db-sg intentionally
# gets none.

# --- Security groups (no inline rules) -----------------------------------

resource "aws_security_group" "public_alb" {
  name        = "${var.name_prefix}-public-alb-sg"
  description = "Public ALB: internet HTTP :80 in, forwards to Web tier."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-alb-sg"
  })
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Web tier: HTTP from public ALB, SSH from admin IP only."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-sg"
  })
}

resource "aws_security_group" "internal_alb" {
  name        = "${var.name_prefix}-internal-alb-sg"
  description = "Internal ALB: HTTP from Web tier only, forwards to App tier :3001."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-internal-alb-sg"
  })
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Application tier: :3001 from internal ALB only, SSH bastion hop from Web tier."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Database tier: MySQL :3306 from Application tier only. No internet exposure, no egress."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-sg"
  })
}

# --- Ingress rules --------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "public_alb_http_from_internet" {
  security_group_id = aws_security_group.public_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Internet HTTP to public ALB"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-alb-http-in"
  })
}

resource "aws_vpc_security_group_ingress_rule" "web_http_from_public_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.public_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "HTTP from public ALB"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-http-from-public-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh_from_admin" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = var.admin_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "SSH from admin IP"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-ssh-from-admin"
  })
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_http_from_web" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "HTTP from Web tier (Nginx /api proxy)"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-internal-alb-http-from-web"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_backend_from_internal_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  description                  = "Backend API from internal ALB"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-backend-from-internal-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh_from_web" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "SSH bastion hop from Web tier"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-ssh-from-web"
  })
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "MySQL from App tier only"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-mysql-from-app"
  })
}

# --- Egress rules ----------------------------------------------------------
# db-sg deliberately has no egress rules: RDS Multi-AZ/read-replica replication
# runs over AWS's managed control-plane network, not through the instance's
# own security group egress.

resource "aws_vpc_security_group_egress_rule" "public_alb_to_web" {
  security_group_id            = aws_security_group.public_alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "Forward HTTP to Web tier"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-alb-to-web"
  })
}

resource "aws_vpc_security_group_egress_rule" "web_http_out" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP outbound (apt/package mirrors)"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-http-out"
  })
}

resource "aws_vpc_security_group_egress_rule" "web_https_out" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS outbound (npm/git/apt)"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-https-out"
  })
}

resource "aws_vpc_security_group_egress_rule" "web_to_internal_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "Proxy /api to internal ALB"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-to-internal-alb"
  })
}

resource "aws_vpc_security_group_egress_rule" "web_ssh_to_app" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "SSH bastion hop to App tier"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-ssh-to-app"
  })
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_to_app" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  description                  = "Forward to App tier backend (target-group port)"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-internal-alb-to-app"
  })
}

resource "aws_vpc_security_group_egress_rule" "app_http_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP outbound via NAT (package updates)"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-http-out"
  })
}

resource "aws_vpc_security_group_egress_rule" "app_https_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS outbound via NAT (package updates)"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-https-out"
  })
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "MySQL to DB tier"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-to-db"
  })
}
