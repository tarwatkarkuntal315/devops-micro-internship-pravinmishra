# Assignment 6 — Building an AI-Assisted Git Safety Net (PR Ready Check)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In Week 2 you built Claude Code hooks that block a dangerous action *before* it happens (`PreToolUse`), and a restricted skill that could look but not touch (`allowed-tools` without `Write`). In this assignment you will discover that Git has the exact same idea, decades older: a **pre-commit hook** that blocks a commit before it's created.

You will build both halves of a real "PR Ready" workflow:

1. A **Git hook that follows fixed rules** — scans staged changes for hardcoded secrets and oversized files and refuses the commit. No AI involved, no guessing, just a rule that gives the same answer every time.
2. A **restricted Claude Code skill** (`/pr-ready`) that reads your staged diff and drafts a Pull Request title, description, and a short list of things worth a second look — the kind of judgment a fixed rule can't make (mixed changes, missing context, unclear intent). The skill never commits, pushes, or opens the PR. You do that yourself, using its draft as a starting point.

This mirrors the Agentic Loop from Week 3's Linux triage assignment: **Gather → Analyze → Human Act → Verify**. The hook and the skill both gather and analyze; only you act.

---

# Task 0 — Confirm Your Fork and Create a Feature Branch

## Goal

Confirm you are working in your own fork, then create a dedicated branch for this assignment.

### Evidence

#### Screenshot 1 — Output of git remote -v and git branch showing the new branch

![Screenshot 1](screenshots/assignment-06/week-04-assignment-06-screenshot-01-remote-and-feature-branch.png)

---

### Notes

**1. Why create a dedicated branch instead of doing this work on main?**

I created a dedicated branch so I could work on the assignment separately without changing the main branch. It also makes the changes easier to review, test, and push safely before merging.

---

# Task 1 — Stage a Change With Realistic Risk

## Goal

On your own fork of this repository (the one you've been submitting your DMI work in since onboarding), create a new branch and stage a change that a real reviewer should catch: a hardcoded-looking secret and a leftover debug statement.

### Evidence

#### Screenshot 2 — Output of  `git status` showing the staged file on feature/ai-pr-ready

![Screenshot 2](screenshots/assignment-06/week-04-assignment-06-screenshot-02-staged-risky-file.png)


---

### Notes

**1. Why does this assignment use an obviously fake key instead of a real one?**

The fake key is used to safely demonstrate how the security checks work without exposing a real AWS credential. It has the same kind of pattern that the hook is designed to detect, but it cannot be used to access a real account.

---

# Task 2 — Write a Real Git Pre-Commit Hook

## Goal

Create a tracked, shareable pre-commit hook that blocks a commit containing secret-like patterns or files over 1MB.

### Evidence

#### Screenshot 3 — `hooks/pre-commit` open in VS Code showing the full script

![Screenshot 3](screenshots/assignment-06/week-04-assignment-06-screenshot-03-pre-commit-hook.png)


---

#### Screenshot 4 — Output of `git config core.hooksPath` confirming it points to `hooks`

![Screenshot 4](screenshots/assignment-06/week-04-assignment-06-screenshot-04-core-hooks-path.png)

---

### Notes

**1. Why is `hooks/pre-commit` tracked in the repo instead of living only in `.git/hooks/`?**

A tracked hook can be stored in the repository and shared with the team. The `.git/hooks/` folder is local to one Git clone, so other team members would not automatically get the same safety check.


---

**2. Compare this to `PreToolUse` from Week 2 Assignment 6. What does each one intercept, and what do they have in common?**

`PreToolUse` intercepts an AI tool action before Claude executes it. The Git pre-commit hook intercepts a Git commit before it is created. Both are safety gates that check an action before it happens and can block the action when a rule is violated.

---

# Task 3 — Prove the Hook Blocks the Risky Commit

## Goal

Attempt to commit the staged file from Task 1 and show the hook rejecting it.

### Evidence

#### Screenshot 5 — Terminal showing `git commit` rejected with the hook's "BLOCKED" message naming the exact file

![Screenshot 5](screenshots/assignment-06/week-04-assignment-06-screenshot-05-blocked-commit.png)

---

### Notes

**1. Which line in `hooks/pre-commit` matched your fake key, and why did it match?**

The secret check matched the pattern `AKIA[0-9A-Z]{16}` in the pre-commit hook. The value `AKIAABCDEFGHIJKLMNOP` starts with `AKIA` and is followed by 16 uppercase letters, so it matched the rule.

---

**2. Could this hook have caught a poorly-named variable that stores a secret without the `AKIA` prefix? What does that tell you about the limits of a fixed rule like this?**

No. A secret stored in a poorly named variable without a matching pattern could pass this check. This shows that fixed rules are useful for known patterns, but they cannot identify every possible secret.

---

# Task 4 — Build the `/pr-ready` Skill

## Goal

Create a manually invoked Claude Code skill that reads your staged changes and produces a PR-readiness report and a draft PR description — without writing, committing, or pushing anything itself.

### Evidence

#### Screenshot 6 — `SKILL.md` frontmatter showing `allowed-tools: Bash, Read, Grep` (no `Write`) and `disable-model-invocation: true`

![Screenshot 6](screenshots/assignment-06/week-04-assignment-06-screenshot-06-pr-ready-skill.png)

---

#### Screenshot 7 — `/pr-ready` output while the risky file is still staged, showing it flagged the secret and/or debug statement

![Screenshot 7](screenshots/assignment-06/week-04-assignment-06-screenshot-07-pr-ready-risk-report.png)

---

### Notes

**1. Why does `/pr-ready` have `Bash` and `Read` but not `Write`?**

Bash and Read allow `/pr-ready` to inspect the Git status and staged diff. It does not have Write because the skill should only review and give advice. It should not modify files or perform Git actions on its own.

---

**2. The pre-commit hook and `/pr-ready` both looked at the same staged diff. Did they flag the same things? What did one catch that the other didn't?**

They both identified the credential-shaped value and the debug statement. The pre-commit hook used fixed rules and blocked the commit because of the secret pattern. `/pr-ready` also looked at the change more broadly and provided review comments and a draft PR description.

---

# Task 5 — Fix the Issues and Re-Verify

## Goal

Remove the secret and debug statement, then prove both gates now pass clean.

### Evidence

#### Screenshot 8 — `git commit` succeeding after the fix (no BLOCKED message)

![Screenshot 8](screenshots/assignment-06/week-04-assignment-06-screenshot-08-clean-commit.png)

---

#### Screenshot 9 — Second `/pr-ready` run showing a clean risk report and a drafted PR title + description

![Screenshot 9](screenshots/assignment-06/week-04-assignment-06-screenshot-09-pr-ready-clean-report.png)

---

### Notes

**1. What exactly did you change to satisfy the pre-commit hook?**

I removed the fake AWS access-key value and the debug `echo` statement from `scripts/notify.sh`. I kept the script as a simple notification script so that the staged change no longer contained the risky patterns detected by the pre-commit hook.

---

# Task 6 — Push and Open a Pull Request Using the AI Draft

## Goal

Push your branch and open a real Pull Request, using `/pr-ready`'s drafted title and description as your starting point — read it critically and edit before you use it.

**Important:** Open this Pull Request with base repository set to **your own fork** — not the shared upstream `pravinmishraaws/devops-micro-internship-pravinmishra` repository. This assignment's hook and skill files are your own practice work, not a change meant for the shared class repo.

### Evidence

#### Screenshot 10 — Your Pull Request showing the base repository is your own fork, plus the title and description, with the `/pr-ready` draft visible for comparison (paste it in the PR conversation or your notes below)

![Screenshot 10](screenshots/assignment-06/week-04-assignment-06-screenshot-10-pull-request.png)


---

#### PR Link

https://github.com/tarwatkarkuntal315/devops-micro-internship-interviews/pull/1

---

### Notes

**1. What, if anything, did you edit in the AI's drafted PR description before using it? Why?**

I reviewed the AI-generated description and replaced the unrelated template content with a description that matched the actual Assignment 06 changes. I included the pre-commit hook, the `/pr-ready` skill, the testing performed, and the final clean state.

---

**2. If you had blindly copy-pasted the AI's draft without reading it, what could go wrong?**

The draft could contain incorrect or unrelated information, especially because it was generated from the earlier staged state. A human review is needed to make sure the title and description accurately represent the final changes.

---

**3. Why does this PR need to target your own fork instead of the shared upstream repository?**

This assignment is practice work for my own fork. Targeting my fork keeps the hook, Claude skill, and notification script separate from the shared upstream repository and avoids creating an unintended change for the main DMI repository.

---

# Task 7 — Map the Workflow to the Agentic Loop

## Goal

Explain this assignment's workflow using the same Gather → Analyze → Human Act → Verify structure from Week 3.

### Notes

**1. Which step(s) represent Gather?**

Gather happens when Git collects the staged changes and status information, and when `/pr-ready` runs `git diff --cached` and `git status` to inspect the actual change.

---

**2. Which step(s) represent Analyze?**

Analyze happens when the pre-commit hook checks the staged files against fixed rules and when `/pr-ready` reviews the staged diff for secrets, debug code, missing context, and other risks.

---

**3. Which step is Human Act, and why must a human — not Claude — run `git commit`, `git push`, and open the PR?**

Human Act is when I fix the issues, run the final Git commands, push the branch, and open the Pull Request. A human must remain responsible for these actions because AI output is advice and can be wrong. The engineer should review the result before changing or sharing the code.

---

**4. Which step is Verify?**

Verify happens after the risky commit is blocked, after the file is fixed and the commit succeeds, and when `/pr-ready` is run again to confirm the cleaned change. The final Pull Request comparison also verifies what will be submitted.

---

**5. In one or two sentences: why do you need *both* the fixed-rule pre-commit hook and the AI skill? Isn't one enough?**

The pre-commit hook provides a fixed and predictable safety gate for known rules, while `/pr-ready` can review the change more broadly and provide context and advice. One cannot fully replace the other, so using both gives us rule-based protection and AI-assisted review.

---

# Task 8 — LinkedIn Post

## Goal

Publish a LinkedIn post summarizing what you built and what you learned about combining fixed-rule safety checks with AI-assisted review.

### Evidence

#### LinkedIn Post URL

https://www.linkedin.com/feed/update/urn:li:activity:7508775710329860096/

---

### LinkedIn Screenshot

![LinkedIn Post](screenshots/assignment-06/week-04-assignment-06-linkedin-post.png)

---

## Key Learnings

Add 3-5 bullet points on what you learned this week.

- Built a Git pre-commit hook that blocked a fake AWS key and a debug statement.
- Created a restricted Claude Code `/pr-ready` skill for staged-change review.
- Learned how fixed-rule checks and AI-assisted review complement each other.
- Practiced keeping a human responsible for commit, push, and Pull Request actions.
- Used the Agentic Loop: Gather → Analyze → Human Act → Verify.

---

# Submission Instructions

- Ensure `hooks/pre-commit` and `.claude/skills/pr-ready/SKILL.md` are committed to your GitHub repository
- Add all required screenshots to your submission
- All written answers must be in your own words
- Do not use a real secret or credential anywhere in your submission — the fake key in Task 1 is intentional and must stay clearly fake
- Open your Pull Request against your own fork, not the shared upstream repository
- Push your final changes to your forked repository
- Include your PR link and LinkedIn post URL

---

## GitHub Repository URL

Paste your forked repository URL here:

https://github.com/tarwatkarkuntal315/devops-micro-internship-interviews

Files added for this assignment:

- `hooks/pre-commit`
- `.claude/skills/pr-ready/SKILL.md`
- `scripts/notify.sh`
  
---

# Completion Checklist

- [x] Branch `feature/ai-pr-ready` created with a staged file containing a fake secret and a debug statement
- [x] `hooks/pre-commit` created and tracked in the repo (not only in `.git/hooks/`)
- [x] `core.hooksPath` configured to point at `hooks/`
- [x] Pre-commit hook shown blocking the risky commit
- [x] `.claude/skills/pr-ready/SKILL.md` created with correct `allowed-tools` (no `Write`) and `disable-model-invocation: true`
- [x] `/pr-ready` run against the risky diff and shown flagging issues
- [x] Risky file fixed; `git commit` succeeds cleanly
- [x] `/pr-ready` re-run showing a clean report and drafted PR title/description
- [x] Pull Request opened using the AI draft as a starting point, with your own fork as the base repository (not upstream), PR link included
- [x] Agentic Loop mapping (Task 7) completed in your own words
- [x] LinkedIn post published and URL submitted
- [x] All required screenshots added
- [x] GitHub repository URL provided

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
