# --- Web tier EC2 instances ----------------------------------------------
#
# One instance per Web subnet, public IP, registered with the public ALB's
# web target group (port 80). Runs Nginx on :80, proxying "/" to a local
# Next.js process on :3000 and "/api/" to the internal ALB - see
# templates/web_user_data.sh.tftpl for the full boot sequence.

resource "aws_instance" "web" {
  for_each = local.web_subnets

  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.web_instance_type
  subnet_id                   = each.value
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [var.web_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.web.name
  associate_public_ip_address = true

  metadata_options {
    http_tokens   = "required" # IMDSv2 only
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  user_data = templatefile("${path.module}/templates/web_user_data.sh.tftpl", {
    repo_url              = var.repo_url
    internal_alb_dns_name = lower(var.internal_alb_dns_name)
    next_public_api_url   = local.next_public_api_url
  })
  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-${each.key}"
  })
}

resource "aws_lb_target_group_attachment" "web" {
  for_each = aws_instance.web

  target_group_arn = var.web_tg_arn
  target_id        = each.value.id
  port             = 80
}
