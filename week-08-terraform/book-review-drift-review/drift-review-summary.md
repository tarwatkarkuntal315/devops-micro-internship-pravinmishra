# Terraform Drift Review Summary

**Author:** Kuntal Tarwatkar
**Program:** DMI Cohort 3 — Week 08, Assignment 06
**Date:** 2026-10-06
**Environment:** Book Review App on AWS `ap-south-1` (69 Terraform-managed resources)

---

## 1. Change Introduced

I deleted the public ALB's inbound HTTP rule (`book-review-public-alb-http-in`, TCP 80 from `0.0.0.0/0`) directly with the AWS CLI (`aws ec2 revoke-security-group-ingress`), without touching any Terraform file.

**Type:** True infrastructure drift. The Terraform configuration did not change; the real AWS infrastructure was changed outside Terraform, so it no longer matched the code and state.

## 2. Evidence Collected

- `terraform plan -detailed-exitcode` returned **exit code 2** (changes pending).
- Terraform warned **"AWS resource not found during refresh"** for `module.security.aws_vpc_security_group_ingress_rule.public_alb_http_from_internet`.
- Plan summary: **1 to add, 0 to change, 0 to destroy** — Terraform planned to re-create the missing rule.
- Plan JSON (`reports/tfplan.json`, queried with targeted `jq` only): `change.actions = ["create"]`, `cidr_ipv4 = "0.0.0.0/0"`, port 80.
- Saved report: `reports/drift-detected-report.txt` — WARN 1, PASS 1, FAIL 1, **Overall Status: FAIL**, script exit code 2.

## 3. Risk Assessment

- **Bash check:** no delete or replace actions (PASS), but one ingress rule in the plan opens `0.0.0.0/0` (FAIL), and changes are pending (WARN).
- **Claude Code (`/tf-drift-review`):** the flagged rule is the one intended internet-facing exception defined in `CLAUDE.md` (public ALB on port 80); no other tier would be exposed. The real risk was **availability**: with the rule gone, the public ALB had no inbound HTTP rule and the app was unreachable from the internet. The pending change was low risk — a single non-destructive create matching the approved configuration. The process concern was a manual change to production outside Terraform.

## 4. Human-Approved Action

I ran `terraform plan` myself, confirmed it showed only one resource — `public_alb_http_from_internet`, **1 to add, 0 to change, 0 to destroy** — and then ran `terraform apply`, reviewed the plan again at the prompt and typed `yes`. Terraform re-created the rule (new ID `sgr-08c7e8540ffeb8cdb`). Claude never ran apply: it refused, and the `PreToolUse` hook blocked a Bash call containing `terraform apply` while the report said FAIL.

## 5. Verification

- `/tf-drift-review` re-ran the script after the fix: **Overall Status: HEALTHY**, PASS 3, WARN 0, FAIL 0, plan exit code **0**, script exit code 0.
- Saved as `reports/resolved-report.txt`.
- The public application URL returned **HTTP 200** again.

## 6. Safety Decision

Gathering and analysing evidence is read-only and cannot harm the environment, so Claude was allowed to run the script, read the report and query the plan JSON. Infrastructure-changing actions can delete data, cause outages or expose services, so they stay with the human. This was enforced in layers: the `CLAUDE.md` safety rules, the Skill's restricted tools (`Bash`, `Read`, `Grep` — no `Write`), `ask`/`deny` permission rules for `apply`, `destroy` and `-auto-approve`, and the deterministic `PreToolUse` hook that blocks `terraform apply` whenever the latest report shows FAIL.

## 7. Agentic Loop Mapping

| Step | What happened |
|---|---|
| **Gather** | `tf-drift-check.sh` ran `terraform plan -detailed-exitcode`, exported the plan JSON and wrote `reports/tf-drift-report.txt`. |
| **Analyze** | `jq` checks flagged the open ingress rule; `/tf-drift-review` explained the cause (true drift), the risk (availability, intended rule) and recommended a human-reviewed apply. |
| **Human Act** | I reviewed `terraform plan` and ran `terraform apply` manually; Claude's attempt path was blocked by the hook. |
| **Verify** | `/tf-drift-review` ran again → HEALTHY, exit code 0; `resolved-report.txt` saved. |
