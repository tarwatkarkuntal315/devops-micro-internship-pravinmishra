#!/bin/bash
# Author: Kuntal Tarwatkar
# PostToolUse hook: after Claude edits a Terraform file, run fmt then validate
# and feed the result back to Claude. Exit 2 = validation failed (Claude must fix).

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

# Only react to Terraform files
case "$file" in
  *.tf|*.tfvars) ;;
  *) exit 0 ;;
esac

tf_dir="${CLAUDE_PROJECT_DIR}/terraform"

if ! fmt_out=$(terraform -chdir="$tf_dir" fmt -recursive 2>&1); then
  echo "terraform fmt failed:" >&2
  echo "$fmt_out" >&2
  exit 2
fi
[ -n "$fmt_out" ] && echo "terraform fmt reformatted: $fmt_out"

# validate is only meaningful after terraform init
if [ ! -d "$tf_dir/.terraform" ]; then
  echo "terraform fmt OK (validate skipped: run terraform init first)"
  exit 0
fi

if val_out=$(terraform -chdir="$tf_dir" validate -no-color 2>&1); then
  echo "terraform fmt OK | terraform validate: $val_out"
  exit 0
else
  echo "terraform validate FAILED after editing $file:" >&2
  echo "$val_out" >&2
  exit 2
fi
