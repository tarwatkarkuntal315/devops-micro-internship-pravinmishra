# Troubleshooting 01 — RDS read replica rejected (managed master password)

Project: Book Review App capstone (AWS ap-south-1) · Student: Kuntal Tarwatkar · Date: 2026-10-06

## 1. Observe
First `terraform apply "tfplan"` stopped with 65 of 66 resources created:

```
Error: creating RDS DB Instance (read replica) (book-review-mysql-replica):
operation error RDS: CreateDBInstanceReadReplica, StatusCode: 400,
api error InvalidParameterValue: Creating read replicas for source instance
with engine mysql where ManageMasterUserPassword is enabled is not supported.
  with module.database.aws_db_instance.replica, on modules\database\main.tf line 82
```

## 2. Collect evidence
- `terraform state list`: network, security, ALBs, 4 EC2, RDS primary all in state; only the replica missing.
- `aws rds describe-db-instances`: `book-review-mysql` = available, MultiAZ = True, PubliclyAccessible = False.

## 3. Identify the failing layer
Database layer, AWS API (not Terraform syntax). `validate` and `plan` passed, because this rule is only enforced by RDS at create time.

## 4. Root cause
The primary used `manage_master_user_password = true` (password managed by RDS in Secrets Manager).
RDS for MySQL does not support creating a read replica from a source with an RDS-managed master password.
The read replica is a hard requirement of the capstone, so the password design had to change, not the replica.

## 5. One controlled fix
`modules/database/main.tf`:
- `random_password.db_master` generates the password (24 chars, RDS-safe specials)
- stored in our own `aws_secretsmanager_secret` as `{"username","password"}` (same JSON shape, so app user data is unchanged)
- primary uses `password = random_password.db_master.result` instead of `manage_master_user_password`
- `master_user_secret_arn` output now points to the new secret; app IAM policy still scoped to that one ARN

Trade-off accepted: password now also lives in the local, git-ignored `terraform.tfstate` (like the JWT). Production: remote S3 state with SSE-KMS.

## 6. Verify the fix before applying
`terraform init` (random 3.9.1) -> `validate` Success -> plan reviewed:
`Plan: 8 to add, 2 to change, 4 to destroy`
- RDS primary **updated in-place** (no replacement, no data loss)
- read replica + random_password + secret + secret version **created**
- app EC2 a/b + their target-group attachments **replaced** (user data references the new secret ARN)
- web tier, ALBs, network, security: unchanged

## 7. Retest
Human-approved `terraform apply`, then confirm replica `available` and app targets healthy.
