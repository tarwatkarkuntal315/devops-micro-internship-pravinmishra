# Project Overview

This project provisions the Book Review App infrastructure using Terraform.

A read-only Bash workflow checks the Terraform plan for destructive changes and unsafe ingress rules before infrastructure changes are approved.

- Owner: Kuntal Tarwatkar (DMI Cohort 3, Week 08 Assignment 06)
- Cloud: AWS `ap-south-1`. Three-tier stack: public ALB -> Web EC2 (Nginx + Next.js) -> internal ALB -> App EC2 (Express :3001) -> RDS MySQL (Multi-AZ + read replica).
- Terraform root module: `terraform/` (modules in `terraform/modules/`)
- Drift check script: `AI Assignment/tf-drift-check.sh`
- Reports: `reports/` (`tf-drift-report.txt` is always the latest run)
- Security rules are separate `aws_vpc_security_group_ingress_rule` resources (`cidr_ipv4`), not inline `ingress` blocks. The public ALB rule allowing `0.0.0.0/0` on port 80 is intentional; every other tier must never be open to the internet.

# Review Workflow

Always follow this order:

1. Gather evidence using Terraform plan data.
2. Analyze the evidence for destructive actions and unsafe ingress rules.
3. Present the findings to the human operator.
4. The human reviews and performs any approved infrastructure-changing action.
5. Verify the infrastructure again after the action.

# Safety Rules

- Never run terraform apply automatically.
- Never run terraform destroy.
- Never use -auto-approve.
- Never edit Terraform files while performing the drift review.
- Use the generated drift report and Terraform plan JSON as the primary evidence.
- Recommend whether an apply appears safe based on the evidence, but never execute it.
- Do not claim a change is safe unless the available evidence supports that conclusion.
- `reports/tfplan.json` contains sensitive values in plain text (e.g. the DB password). Query it only with targeted `jq` filters on flagged resources; never print the whole file, `.variables`, or any sensitive attribute.
- Never read `terraform.tfvars` or `*.tfstate` files.

# Output Rules

When analyzing a Terraform drift report, show:

1. Overall status.
2. Terraform detailed exit code and its meaning.
3. Any destructive resource changes.
4. Any security rule exposing access through 0.0.0.0/0 or *.
5. A plain-language risk assessment.
6. A recommended next step for the human operator.
