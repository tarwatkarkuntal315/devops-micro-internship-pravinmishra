# Architecture & Security Review — Phases 1–2 (Network + Security)

Project: Book Review App capstone (AWS ap-south-1) · Student: Kuntal Tarwatkar
Reviewer: `architecture-security-reviewer` subagent (read-only) · Date: 2026-10-06
Scope: `terraform/` root, `modules/network`, `modules/security` (ALB, RDS, EC2 not built yet)

### PASS
- VPC 10.0.0.0/16, six non-overlapping subnets across 2 AZs, matches design — modules/network/main.tf:10-40
- `map_public_ip_on_launch` true only for web tier — modules/network/main.tf:34
- Routing: public RT -> IGW (web only), app RT -> single NAT GW, DB RT has no route (no internet path) — modules/network/main.tf:84-119
- Only one internet-open ingress rule (public ALB :80 from 0.0.0.0/0); all else SG-to-SG chained — modules/security/main.tf:76-165
- Port 3001 reachable only from internal-alb-sg — modules/security/main.tf:128-139
- Port 3306 reachable only from app-sg; db-sg has zero egress — modules/security/main.tf:154-165
- `admin_cidr` enforced as single /32 via validation, no default — variables.tf:31-39
- SSH model: admin -> web only; web -> app bastion hop modelled in both directions — modules/security/main.tf:141-152, 224-235
- ALB egress ports match target ports: public-alb -> web 80, internal-alb -> app 3001 — modules/security/main.tf:172-183, 237-248
- No secrets/credentials; outputs are IDs only
- .gitignore covers .terraform/, *.tfstate*, terraform.tfvars, *.tfplan, *.pem, .env*
- `terraform validate` Success; `fmt -check` clean; hashicorp/aws 6.67.0 locked
- Logical modules (network, security); dependencies passed via module inputs/outputs
- Single NAT Gateway documented as approved trade-off in code and diagram

### WARN
- `nat_gateway_subnet_key` (default "web_a") has no validation forcing a web-tier subnet — modules/network/variables.tf:25-29
- Single NAT Gateway = SPOF for App-tier egress only (approved cost trade-off, not a blocker)
- Root does not pass a `tags` map into modules (relies on provider default_tags) — revisit when compute adds per-instance tags
- web-sg / app-sg egress 80/443 to 0.0.0.0/0: broad by CIDR but port-scoped for package installs — acceptable for lab

### FAIL
- None found in Phase 1–2 scope.

### Recommended Next Checks
- Phase 3: public ALB internet-facing in web subnets, internal ALB internal in app subnets, ports 80/3001 and health checks per diagram
- Phase 4: RDS Multi-AZ, `publicly_accessible = false`, DB subnet group in DB subnets, read replica, DB_PASS/JWT_SECRET as sensitive variables only
- Phase 5: web EC2 public IP + key handling (no private key committed), app EC2 no public IP, user data without hard-coded secrets, correct SG attachments
- Re-run this review after Phases 3–5

### Follow-up decisions
- WARN 1 accepted and fixed: added validation so `nat_gateway_subnet_key` must be a web-tier subnet.
- WARN 2–4 accepted as documented lab trade-offs.
