# Book Review App - Phase 3 load-balancing module
#
# Builds the two Application Load Balancers described in
# docs/architecture-diagram.html:
#
#   Internet -> public ALB (web subnets, public-alb-sg) -> Web tier
#   Web tier -> internal ALB (app subnets, internal-alb-sg) -> App tier :3001
#
# LAB GAP: both listeners are plain HTTP:80. There is no ACM certificate or
# custom domain in this lab, so there is no TLS anywhere on the path
# (browser -> public ALB, or Web tier -> internal ALB). Document this as a
# production gap, not an oversight, before any real deployment.
#
# This module creates ALBs, target groups, and listeners ONLY. Target-group
# attachments are deliberately left out of this module and instead live in
# the compute module, because compute's user data needs the ALB DNS names
# (Web-tier Nginx proxies /api to the internal ALB DNS name; the frontend
# build uses NEXT_PUBLIC_API_URL=http://<public ALB DNS>). Creating the
# attachments here would require the alb module to depend on compute's
# instance IDs, creating a cycle - so attachments are deferred to the
# module that already depends on this one.

resource "aws_lb" "public" {
  name               = "${var.name_prefix}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg_id]
  subnets            = var.web_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-alb"
  })
}

resource "aws_lb" "internal" {
  name               = "${var.name_prefix}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.app_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-internal-alb"
  })
}

# --- Target groups -----------------------------------------------------
#
# target_type = "instance" for both: targets are registered later (compute
# module) by EC2 instance ID, not by IP or Lambda ARN.

resource "aws_lb_target_group" "web" {
  name        = "${var.name_prefix}-web-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-tg"
  })
}

resource "aws_lb_target_group" "app" {
  name        = "${var.name_prefix}-app-tg"
  port        = 3001
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-tg"
  })
}

# --- Listeners -----------------------------------------------------------

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-alb-listener-80"
  })
}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-internal-alb-listener-80"
  })
}
