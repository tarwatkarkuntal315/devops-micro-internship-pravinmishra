# Assignment 4 — Gotto Job: Backlog Refinement & Sprint 1 in Jira

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this 90-minute, time-boxed exercise, you will act as a Scrum team — or run in Solo Mode, playing every role yourself — to turn the Gotto Job template into a value-ordered backlog, estimate the work in story points, plan Sprint 1, open the burndown chart, and ship one small UI-only increment (text, color, spacing, a label, or a CTA — no backend changes).

---

# Task 1 — Roles & Mode Setup (Team vs Solo)

## Goal

Choose Team Mode or Solo Mode, and document how each Scrum role (Product Owner, Scrum Master, Dev Lead, DevOps Lead) was handled.

### Evidence

#### Screenshot 1 — Jira "Create project" screen, or the project sidebar after creation

![Screenshot 1 — Jira project/sidebar](screenshots/assignment-04/week-05-assignment-04-screenshot-01-project-created.png)

---

### Notes

Write one line for each role: PO (what you prioritized), SM (how you ensured process), Dev Lead (what you built), DevOps Lead (how you shipped).

### Notes

- **Product Owner:** Prioritized UI improvements based on user visibility, clarity, and trust.
- **Scrum Master:** Managed the backlog, Sprint planning, estimates, Sprint work, and retrospective.
- **Dev Lead:** Implemented the selected UI improvement and verified the change locally.
- **DevOps Lead:** Committed the change, deployed it to the EC2 server using Nginx, and verified the live result.

---

# Task 2 — Create the Jira Project (Team-managed → Scrum)

## Goal

Create a Team-managed Scrum project named `Gotto Job – Team <#>` (Team Mode) or `Gotto Job – <YourName>` (Solo Mode).

### Evidence

#### Screenshot 2 — Project created page showing the project name and key

![Screenshot 2 — Jira project created](screenshots/assignment-04/week-05-assignment-04-screenshot-02-project-name-key.png)

---

# Task 3 — Create the Epic

## Goal

Create the Epic `Improve Gotto Job UI discoverability & trust` to group the UI improvement initiative.

### Evidence

#### Screenshot 3 — Backlog showing the Epic panel with the Epic visible

![Screenshot 3 — Epic visible](screenshots/assignment-04/week-05-assignment-04-screenshot-03-epic-visible.png)

---

# Task 4 — Seed the Product Backlog (6–8 Stories + Fibonacci Points + Ranking)

## Goal

Create at least six Stories under the Epic, estimate each with 1, 2, or 3 story points, and rank them by value.

### Evidence

#### Screenshot 4 — Backlog showing the Epic and at least six Stories under it

![Screenshot 4 — Ranked backlog](screenshots/assignment-04/week-05-assignment-04-screenshot-04-ranked-backlog.png)

---

#### Screenshot 5 — One Story opened showing its Story Points and acceptance criteria filled in

![Screenshot 5 — Story points and acceptance criteria](screenshots/assignment-04/week-05-assignment-04-screenshot-05-story-acceptance-criteria.png)

---

# Task 5 — Planning Poker (Estimate + Debate Notes)

## Goal

Confirm the Story Points (1, 2, or 3) for each Story and record brief reasoning for each estimate.

### Evidence

#### Screenshot 6 — Backlog showing Story Points visible, or two or three Stories opened showing their points

![Screenshot 6 — Planning poker estimates](screenshots/assignment-04/week-05-assignment-04-screenshot-06-planning-poker-estimates.png)

### Notes

- **GJKT-2 — Clarify advanced search labels — 2 points:** Requires changes to several form labels and placeholders and then verification of the search form.
- **GJKT-3 — Make job titles larger and bolder — 2 points:** Requires CSS/UI changes and checking the job cards across the page.
- **GJKT-4 — Show REMOTE badge on remote job cards — 2 points:** Requires identifying remote job cards, updating the badge text, and verifying the result locally and after deployment.
- **GJKT-5 — Update homepage hero tagline — 1 point:** A small text-only change with limited verification.
- **GJKT-6 — Add prominent Apply Now button — 1 point:** A small UI/CTA change with straightforward verification.
- **GJKT-7 — Update primary CTA color — 1 point:** A small CSS/color change with simple visual verification.
- **GJKT-8 — Add posted date to job cards — 1 point:** A small UI content change with limited implementation work.
- **GJKT-9 — Add About and Contact footer links — 1 point:** A small navigation/footer change with straightforward verification.

In Solo Mode, I reviewed the estimates by considering the amount of UI work, verification required, and deployment effort before confirming the points.

---

# Task 6 — Sprint Planning: Create Sprint 1 + Sprint Goal + Scope

## Goal

Create Sprint 1, move three or four Stories into it (approximately 3–6 points), set the Sprint Goal, and break each selected Story into Build, Verify, Deploy, and Screenshot Sub-tasks.

### Evidence

#### Screenshot 7 — Sprint 1 with the selected Stories inside it

![Screenshot 7 — Sprint 1 selected Stories](screenshots/assignment-04/week-05-assignment-04-screenshot-07-sprint-1-selected-stories.png)

---

#### Screenshot 8 — One Story showing the Sub-tasks created

![Screenshot 8 — Story subtasks](screenshots/assignment-04/week-06-assignment-04-screenshot-08-gjkt-2-subtasks.png)

---

# Task 7 — Reports: Open Burndown Chart

## Goal

Open the Burndown Chart and confirm it exists for Sprint 1. It is acceptable if the chart is not yet populated.

### Evidence

#### Screenshot 9 — Burndown Chart page opened, even if empty

![Screenshot 9 — Burndown Chart](screenshots/assignment-04/week-06-assignment-04-screenshot-09-gjkt-3-subtasks.png)

---

# Task 8 — Ship One Small Increment (Build + Deploy + Proof)

## Goal

Implement one small UI-only Story from Sprint 1, commit it, deploy it live, and move the Story and its Sub-tasks to Done in Jira.

### Evidence

#### Screenshot 10 — Jira board showing the Story moved to Done

![Screenshot 10 — Jira board Story Done](screenshots/assignment-04/week-05-assignment-04-screenshot-10-jira-board-story-done.png)

---

#### Screenshot 11 — Git commit output

![Screenshot 11 — Git commit](screenshots/assignment-04/week-05-assignment-04-screenshot-11-git-commit.png)

---

#### Screenshot 12 — Live URL in the browser showing the UI change, with the URL visible

![Screenshot 12 — Live Gotto Job UI](screenshots/assignment-04/week-05-assignment-04-screenshot-12-live-url-ui-change.png)

**Live URL:** http://34.204.40.36/job-listings.html

The live page was verified after deployment, and the remote job cards displayed the `REMOTE` badge.

---

# Task 9 — Retro Notes (Scrum Pillar + Value)

## Goal

Add a retro comment covering what went well, what to improve, one Scrum pillar observed (Transparency, Inspection, or Adaptation), and one Scrum value (Openness, Focus, Commitment, Courage, or Respect).

**What went well:**  
The backlog was refined and estimated clearly, and Sprint 1 had a focused goal. We successfully implemented, verified, and deployed the REMOTE badge UI improvement to EC2.

**What could be improved:**  
The initial project setup and deployment preparation took more time than expected. The workflow can be made smoother by preparing the local project and deployment steps earlier.

**Action for next sprint:**  
Prepare the development and deployment environment before starting implementation, and continue breaking stories into small Build, Verify, Deploy, and Screenshot tasks.

**Scrum Pillar — Transparency:**  
The backlog, Sprint scope, progress, and deployment result were kept visible in Jira.

**Scrum Value — Commitment:**  
I focused on completing the selected Sprint 1 story and its Build, Verify, Deploy, and Screenshot tasks.

### Evidence

#### Screenshot 13 — Jira retro comment visible

![Screenshot 13 — Sprint retrospective](screenshots/assignment-04/week-05-assignment-04-screenshot-13-retrospective.png)

---

# Task 10 — LinkedIn Post (Mandatory)

## Goal

Publish a LinkedIn post about what you delivered, including your live URL, three to five lines on what you did and learned, and one screenshot (Burndown Chart, Sprint board, or the live UI change).

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

https://www.linkedin.com/feed/update/urn:li:activity:7509211395943583746/

---

#### Screenshot 14 — Published LinkedIn post

![Screenshot 14 — LinkedIn published post](screenshots/assignment-04/week-05-assignment-04-screenshot-14-linkedin-published.png)

---

# Submission Instructions

- Add all 14 required screenshots
- Full name must be visible in required screenshots
- Do not expose sensitive information (keys, passwords, account IDs)

---

# Completion Checklist

- [x] Task 1: Team Mode or Solo Mode selected and all four roles documented (Screenshot 1 & Notes)
- [x] Task 2: Team-managed Scrum project created with the required name (Screenshot 2)
- [x] Task 3: UI improvement Epic created (Screenshot 3)
- [x] Task 4: 6–8 Stories added under the Epic and ranked by value (Screenshots 4 & 5)
- [x] Task 5: Story Points set (1, 2, or 3) with reasoning recorded (Screenshot 6 & Notes)
- [x] Task 6: Sprint 1 created with Sprint Goal, 3–4 Stories, and Sub-tasks (Screenshots 7 & 8)
- [x] Task 7: Burndown Chart opened (Screenshot 9)
- [x] Task 8: One UI-only increment implemented, committed, deployed, and verified (Screenshots 10–12)
- [x] Task 9: Retro comment with one Scrum pillar and one Scrum value (Screenshot 13)
- [x] Task 10: Mandatory LinkedIn post published with the live URL, backlog refinement, Sprint planning, one shipped increment, proof, and Screenshot 14
- [x] Task 11: All required screenshots added 
- [x] Full Name visible in required screenshots 
- [x] No sensitive data exposed

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
