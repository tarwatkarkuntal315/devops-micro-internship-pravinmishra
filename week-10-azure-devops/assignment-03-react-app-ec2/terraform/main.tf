# Default VPC keeps this lab small; the instance gets a public IP in a default public subnet.
data "aws_vpc" "default" {
  default = true
}

# Latest Ubuntu 24.04 LTS (x86_64) published by Canonical in the selected region,
# so no AMI ID is hard-coded or copied from another region.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "admin" {
  key_name   = "${var.project_name}-admin"
  public_key = file(pathexpand(var.admin_public_key_path))
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "HTTP from anywhere, SSH only from approved sources"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = var.ssh_allowed_cidrs

  security_group_id = aws_security_group.web.id
  description       = "SSH from ${each.key}"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP for browser access"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Outbound for apt and GitHub"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.admin.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  tags = {
    Name = "${var.project_name}-web"
  }
}
