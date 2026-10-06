# --- Application tier EC2 instances ---------------------------------------
#
# One instance per App subnet, no public IP, registered with the internal
# ALB's app target group (port 3001). Runs the Express backend under PM2 -
# see templates/app_user_data.sh.tftpl for the full boot sequence,
# including the staggered start for the second instance (AZ "b") that
# mitigates (but does not eliminate) the double-seed race on first boot.

resource "aws_instance" "app" {
  for_each = local.app_subnets

  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.app_instance_type
  subnet_id                   = each.value
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [var.app_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.app.name
  associate_public_ip_address = false

  metadata_options {
    http_tokens   = "required" # IMDSv2 only
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  user_data = templatefile("${path.module}/templates/app_user_data.sh.tftpl", {
    repo_url          = var.repo_url
    db_host           = var.db_endpoint_address
    db_port           = var.db_port
    db_name           = var.db_name
    db_user           = var.db_username
    master_secret_arn = var.master_user_secret_arn
    jwt_param_name    = aws_ssm_parameter.jwt_secret.name
    region            = var.region
    allowed_origins   = local.public_alb_url
    delay_seconds     = each.key == "b" ? var.app_start_delay_seconds : 0
  })
  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-${each.key}"
  })
}

resource "aws_lb_target_group_attachment" "app" {
  for_each = aws_instance.app

  target_group_arn = var.app_tg_arn
  target_id        = each.value.id
  port             = 3001
}
