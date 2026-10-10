# Week 08: Terraform — From One VM to a Self-Checking Three-Tier Stack

This week I stopped clicking through cloud consoles and started describing infrastructure as code. Six assignments, each adding one idea:

1. **Azure VM.** My first `main.tf`, and the loop I now use every time: init → plan → apply → verify → destroy.
2. **AWS EC2 + Nginx.** A custom VPC with public and private subnets. A subnet is public because of its route table, not its name.
3. **React on Azure.** A cloud-init script passed through `custom_data` built and served the app on first boot, with no SSH needed.
4. **EpicBook with modules.** Network, EC2 and RDS modules. MySQL stayed private and accepted traffic only from the app's security group.
5. **Capstone.** A three-tier Book Review App: public ALB, web tier, internal ALB, private API, Multi-AZ RDS with a read replica. That's 66 resources, built with Claude Code subagents, Terraform MCP and validation hooks. I approved every plan and rejected a wrong port suggestion.
6. **Drift review.** A Bash + `jq` check on the plan JSON, a Claude Skill to explain it, and a hook that blocks `apply` on FAIL. I deleted a security rule by hand. It was caught, blocked, fixed by me, and verified healthy.

**What I learned:**

- Read the plan's actions, not just the counts. "1 to add" was a rule open to the whole internet.
- Reference security groups, not IP ranges.
- AI is a strong pair engineer, but humans own `apply`.
- Destroy what you don't need.

Code: https://github.com/tarwatkarkuntal315/devops-micro-internship-pravinmishra/tree/main/week-08-terraform

P.S. This post is part of the DevOps Micro Internship (DMI) — Self-Paced Engineer Track — by Pravin Mishra. My graded progress is public: https://dmi.pravinmishra.com/s/tarwatkarkuntal315.html · Start your DevOps journey: https://dmi.pravinmishra.com/?utm_source=student&utm_medium=ps-blog&utm_campaign=self-paced
