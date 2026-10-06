#!/bin/bash
# Author: Kuntal Tarwatkar
# PreToolUse hook (Bash): block any "terraform apply" that Claude tries to run
# while the latest drift report says "Overall Status: FAIL".
# The hook makes no infrastructure decision itself - it only reads the report.

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' | tr -d '\r')

# Matches "terraform apply", "terraform -chdir=x apply", "terraform.exe apply", ...
if ! printf '%s' "$command" | grep -Eq 'terraform(\.exe)?([[:space:]]+-[^[:space:]]+)*[[:space:]]+apply\b'
then
  exit 0
fi

report="${CLAUDE_PROJECT_DIR}/reports/tf-drift-report.txt"

if [ -f "$report" ] && grep -q '^Overall Status: FAIL' "$report"
then
  reason="BLOCKED: the latest drift review (reports/tf-drift-report.txt) shows 'Overall Status: FAIL'. Review and resolve the failing findings, then re-run /tf-drift-review before any terraform apply. Infrastructure-changing commands must be run manually by the human operator."
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
fi

exit 0
