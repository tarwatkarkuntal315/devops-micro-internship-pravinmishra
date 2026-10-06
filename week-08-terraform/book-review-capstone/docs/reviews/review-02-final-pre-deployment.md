# Architecture & Security Review — Final Pre-Deployment (all phases)

Project: Book Review App capstone (AWS ap-south-1) · Student: Kuntal Tarwatkar
Reviewer: `architecture-security-reviewer` subagent (read-only) · Date: 2026-10-06
Scope: `terraform/` root + modules network, security, alb, database, compute (+ user-data templates)
Checks run: `terraform fmt -check -recursive` clean · `terraform validate` Success (hashicorp/aws 6.67.0)

### PASS
- VPC 10.0.0.0/16, 6 non-overlapping subnets, 2 AZs; web public, app + db private — modules/network/main.tf:10-46
- Routing: public RT -> IGW (web), app RT -> single NAT, db RT has no route — modules/network/main.tf:84-119
- SG chain public-alb -> web -> internal-alb -> app -> db, tier rules by SG reference — modules/security/main.tf
- Backend :3001 only from internal-alb-sg; MySQL :3306 only from app-sg; db-sg no egress — modules/security/main.tf:128-165
- Public ALB internet-facing (web subnets); internal ALB `internal = true` (app subnets); 80 -> web:80, 80 -> app:3001; health check `/` verified against backend `app.get("/")` — modules/alb/main.tf:23-138
- Target-group attachments in compute module (no alb <-> compute cycle) — modules/compute/web.tf:42-48, app.tf:50-56
- RDS MySQL Multi-AZ + read replica, `publicly_accessible = false` on both, encrypted, `manage_master_user_password = true` — modules/database/main.tf:33-102
- App EC2: no public IP, IMDSv2 required, encrypted gp3 — modules/compute/app.tf:9-29
- Web EC2: public IP by design, IMDSv2 required, encrypted — modules/compute/web.tf:8-28
- IAM least privilege: web = SSM only; app = SSM + GetSecretValue on the one DB secret + GetParameter on the one JWT parameter — modules/compute/iam.tf:20-103
- Secrets: DB password never in Terraform (Secrets Manager, fetched at boot); JWT in SSM SecureString; no secrets in user data, logs or outputs
- User data: Node version check, PM2 ecosystem file built with `jq` (mode 600), `PORT=3001`, `ALLOWED_ORIGINS` = public ALB URL, Nginx keeps `/api` prefix and re-resolves internal ALB DNS
- `.gitignore` covers state, tfvars, keys, .env; none tracked in git
- Acyclic dependency graph; all names within AWS length limits; no duplicated resources

### WARN
- `jwt_secret` is stored in plaintext in local `terraform.tfstate` (git-ignored). Production: remote S3 backend with SSE-KMS + locking — modules/compute/main.tf:50-59
- App IAM policy has no explicit `kms:Decrypt` (relies on AWS-managed key policies) — verify on first boot in `/var/log/book-review-setup.log`
- Single NAT Gateway = SPOF for App-tier egress (approved cost trade-off)
- HTTP only on both ALBs (no domain/ACM in lab) — production gap
- AL2023 Node package names may change; script verifies version and logs FATAL
- Cost (hourly): 1 NAT GW, 2 ALBs, RDS Multi-AZ + read replica, 2 x t3.small + 2 x t3.micro — destroy after evidence
- Optional production enhancements not in scope: ALB access logs, RDS Performance Insights, CloudWatch alarms

### FAIL
- None. All CLAUDE.md "Required Architecture" items are satisfied.

### Recommended Next Checks
- Human review of `terraform plan`: expected creates only, no replacements/deletions
- After apply: check `/var/log/book-review-setup.log` on one app and one web instance
- Confirm `bookreview` database exists before backend `sync()` (app logs)
- Confirm `admin_cidr` in `terraform.tfvars` is the current /32 before apply

### Lead fixes made before this review (human-in-the-loop)
- Internal ALB SG egress corrected from 80 to 3001 (ALB connects on the target port)
- Added web-sg egress 22 -> app-sg (bastion hop was blocked)
- `NEXT_PUBLIC_API_URL` must end in `/api` (found by reading `api.js` vs Express routes)
- User data: fixed `pm2 startup` handling that would have aborted the web script before Nginx was configured; added npm fallback link

### Post-deployment updates (after this review)
- RDS master password changed from `manage_master_user_password = true` to `random_password` stored in our own Secrets Manager secret: RDS for MySQL rejects a read replica when the password is RDS-managed (see `docs/troubleshooting/01-rds-read-replica-managed-password.md`). The DB password is now also in local, git-ignored state, the same accepted trade-off as the JWT.
- Nginx rewrite `/api/api/` -> `/api/` added for the home page's doubled API prefix (see `docs/troubleshooting/02-homepage-no-books-double-api-prefix.md`).
- Deployment verified end to end, then destroyed on 2026-10-06.
