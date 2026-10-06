# --- IAM: shared EC2 assume-role policy ----------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# --- Web tier role: SSM only ---------------------------------------------
#
# Web instances hold no application secrets - AmazonSSMManagedInstanceCore
# (for Session Manager access, an alternative to the SSH bastion hop) is
# the only permission they need.

resource "aws_iam_role" "web" {
  name               = "${var.name_prefix}-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-role"
  })
}

resource "aws_iam_role_policy_attachment" "web_ssm" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.name_prefix}-web-profile"
  role = aws_iam_role.web.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-profile"
  })
}

# --- App tier role: SSM + least-privilege secret access ------------------
#
# App instances additionally need to read exactly two secrets at boot: the
# RDS-managed master password, and the JWT SSM parameter this module
# creates. The inline policy below is scoped to those two ARNs only - no
# wildcard resources, no other Secrets Manager/SSM permissions.
#
# KMS: no kms:Decrypt statement is included. Both secrets are encrypted
# with their service's AWS-managed key (aws/secretsmanager, aws/ssm), and
# the default key policy AWS attaches to its own managed keys already
# grants decrypt to any principal in the account that is authorized to
# call the owning service's GetSecretValue/GetParameter API, via a
# kms:ViaService condition scoped to that service - verified against the
# AWS-managed-key default policy documentation, not assumed from memory.
# If a customer-managed KMS key is ever substituted for either secret,
# this policy will need an explicit, scoped kms:Decrypt statement (with a
# matching kms:ViaService condition) added back in - note that change
# here if it happens.

resource "aws_iam_role" "app" {
  name               = "${var.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-role"
  })
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "app_secrets" {
  statement {
    sid       = "ReadDbMasterSecret"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.master_user_secret_arn]
  }

  statement {
    sid       = "ReadJwtParameter"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.jwt_secret.arn]
  }
}

resource "aws_iam_role_policy" "app_secrets" {
  name   = "${var.name_prefix}-app-secrets"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app_secrets.json
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name_prefix}-app-profile"
  role = aws_iam_role.app.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-profile"
  })
}
