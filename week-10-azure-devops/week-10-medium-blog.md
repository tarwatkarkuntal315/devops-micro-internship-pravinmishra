# Week 10: CI/CD with Azure DevOps — From a Self-Hosted Agent to AI-Assisted Incident Triage

*Five assignments, two clouds, a dozen pipelines and one lesson that kept coming back: a green pipeline is not the finish line.*

---

Week 10 of the DevOps Micro Internship (DMI) was all about **Azure DevOps Pipelines**. Over five assignments I went from registering a single build agent on a Linux VM to running a two-repository, two-pipeline deployment of a full-stack app on Azure, and then deliberately breaking it so an AI assistant could diagnose it without being allowed to touch anything.

This post walks through what I built, the problems I actually hit (rather than the ones in the tutorials), and what I would tell someone starting the same week.

---

## 1. The foundation: my own build agent

Everything else in the week ran on one machine: a **self-hosted Azure Pipelines agent** on an Ubuntu 22.04 VM in Azure.

- I created a **Personal Access Token** with only *Agent Pools (Read & manage)* and *Build (Read & execute)*, used it once to register the agent, and revoked it as soon as part of it ended up in a screenshot. The agent then uses its own credentials, so the PAT is not needed afterwards anyway.
- I installed the agent as a **systemd service** (`svc.sh install/start`), so it survives reboots and SSH disconnects.
- The VM only needs **outbound HTTPS**. The agent polls Azure DevOps; nothing connects in. SSH was locked to my own IP.

**First real-world surprise:** the cheap B-series VM sizes had *no capacity* in Central India or South India, and another family had a **zero-core quota** on my subscription. Checking `az vm list-usage` and switching region and size took longer than the actual agent setup. Capacity and quota are part of the job, not an edge case.

**Why self-hosted at all?** It has a **fixed public IP**. That turned out to matter in every later assignment, because every target server's firewall could allow SSH from exactly one known address instead of from Microsoft-hosted agents' changing ranges.

---

## 2. Deploying over SSH: a static site to AWS EC2

Next, a cross-cloud pipeline: **Azure DevOps → AWS EC2**.

- **Terraform** created an Ubuntu 24.04 `t3.micro`. The AMI was found with a `data "aws_ami"` lookup rather than a hard-coded ID, and the security group allowed SSH from my IP and the agent IP only.
- **Ansible** installed Nginx and created a dedicated `deployer` user with **key-only** login and **no sudo**, owning `/var/www/html` (no `chmod 777`). Ansible doesn't run natively on Windows, so I ran it from a tiny Docker image.
- The pipeline used an **SSH service connection** with a dedicated deploy key, `CopyFilesOverSSH@0` to replace the web root (excluding `.git` and the pipeline file), and `SSH@0` to verify the deployment and fail unless `curl localhost` returned 200.

**The bug:** "Timed out while waiting for handshake." The cause was not the firewall or the key. The service connection's host was `13.232.17.21` instead of `13.232.17.213`; one missing digit. **Read the log line *before* the error**: it printed the host it was connecting to.

---

## 3. A real multi-stage pipeline: React → Build → Test → Publish → Deploy

Assignment 3 was a proper release pipeline for a React app:

| Stage | What it does |
|-------|--------------|
| **Build** | Node 22 LTS, `npm ci`, `npm run build`, verify `build/index.html`, publish the build as a **pipeline artifact** |
| **Test** | fresh checkout, `npm test -- --watchAll=false` with `CI=true`, so Jest runs once and fails the stage on any failing test |
| **Publish** | download the artifact, verify `index.html` and JS/CSS bundles exist and **no** `src/` or `node_modules/` is present, re-publish as the release artifact |
| **Deploy** | copy the artifact *contents* into Nginx's web root over SSH, then verify with HTTP probes, including an unknown route to prove SPA routing works |

Two lessons from this one:

1. **Stages don't share a disk.** Files built in one stage don't exist in the next unless you publish and download them as artifacts. That's also what makes the release traceable: the bytes you tested are the bytes you deploy.
2. **A green pipeline can still be wrong.** The first run was all green. When I looked at the server, every deployed file was `-rw-rw-rw-`, world-writable, because the SSH copy task keeps the agent's file modes. The fix was two `find … -exec chmod` lines in the deploy step, plus a check that **fails the pipeline** if anything world-writable remains.

This assignment also used **password-based SSH** (an assignment requirement). Rather than enabling passwords for the whole server, Ansible added an `sshd` **`Match User deployer`** block, so only that one account accepts a password and everything else stays key-only.

---

## 4. The capstone: two repos, two pipelines, one working bookstore

The capstone deployed **EpicBook** (Node.js + MySQL) on Azure with an enterprise-style split:

- **`infra-epicbook`**: Terraform only. Three-tier network (frontend, backend, delegated database subnet), NSGs per tier, two Ubuntu VMs, and **Azure Database for MySQL Flexible Server with private access** (private DNS zone, no public endpoint). State lives in an **Azure Storage remote backend**.
- **`theepicbook`**: the app plus Ansible roles (common, database, backend, frontend, verify) and its own pipeline.

**Infra pipeline:** Validate → Plan (saved `tfplan` published as an artifact) → **manual approval** (`ManualValidation@1`) → Apply *the exact reviewed plan* → Outputs.

**App pipeline:** Prepare → Validate → Configure & Deploy → Verify. Nginx proxies to the backend's **private** IP, EpicBook runs as a **systemd service**, and the schema and seed data are imported **only once**, guarded by table and row checks, because the SQL files are plain `INSERT`s.

Between them sits a deliberate **manual handoff**: four non-sensitive Terraform outputs (`app_public_ip`, `backend_ansible_host`, `backend_private_ip`, `mysql_fqdn`) copied into the Ansible inventory in one small commit, which then triggered the app pipeline. It's clunky on purpose; it makes the boundary between teams visible.

**Secrets, kept out of Git, YAML and logs:**

| Secret | Where it lived |
|--------|----------------|
| Azure credentials | an **Azure Resource Manager service connection** (service principal) |
| SSH private key | **Secure Files**, downloaded per job, `chmod 600` |
| MySQL password | a **secret variable group**, mapped to environment variables, written by Ansible into a root-only file with `no_log` |

**The bugs worth remembering:**

- **Quotes disappear between pipeline steps.** I passed `-e ansible_ssh_common_args='-o UserKnownHostsFile=… -o StrictHostKeyChecking=yes'` through a pipeline variable. By the time it reached the next script the quotes were gone, and SSH saw a bare `-o`: *"UNREACHABLE … no argument after keyword -o"*. The fix was to set `ANSIBLE_PRIVATE_KEY_FILE` and `ANSIBLE_SSH_EXTRA_ARGS` instead. Ansible reads them natively, so no quoting is involved, and host-key checking stays strict.
- **Azure MySQL requires TLS, but EpicBook connected with a single URL.** The app passed only the URL to Sequelize, so TLS options were silently ignored. A one-line change, `new Sequelize(url, config)`, plus `dialectOptions.ssl` fixed it.
- **GitHub access scope.** The default OAuth flow wanted admin access to webhooks on *all* my repositories. Installing the **Azure Pipelines GitHub App** with *only select repositories* was the right call, and when the wizard hit a 500 error I created the pipeline with `az pipelines create` against the app connection.

At the end, a book added to the cart in the browser showed up as a row in MySQL. Checkout was proven end to end, through private networking only.

---

## 5. Breaking it on purpose: AI-assisted, read-only triage

The final assignment was the most interesting: **incident response with an AI assistant that is not allowed to fix anything.**

- A **Bash triage script** reads the latest run of both pipelines, downloads the real **step logs** through the Build Logs REST API, sanitizes them, pattern-matches failure categories (dependency, build, test, auth, agent, Terraform, Ansible, unclassified), and returns a meaningful exit code: **0** healthy · **1** warning · **2** failure · **3** tool error.
- A **Claude Code `/pipeline-triage` skill** is manual-only (`disable-model-invocation: true`) and pre-approved to run exactly one command. A `CLAUDE.md` defines the workflow and safety rules, and **permission deny-rules** actually block edits, pushes, pipeline runs, Terraform, Ansible and secret access.

**The drill:** on a throwaway branch I added a non-existent Ansible collection to `requirements.yml`. The app pipeline failed in its *first* stage, before any SSH or deployment.

**Gather → Analyze → Human Act → Verify:**

1. **Gather:** the script classified it as a *Dependency Installation Failure*, exit code 2.
2. **Analyze:** Claude quoted the exact lines (`ERROR! Failed to resolve the requested dependencies map… dmidrill.does_not_exist`), explained the cause, recommended one fix, and ended with *"I have not changed any file or pipeline."*
3. **Human Act:** I removed the line myself and re-ran the pipeline.
4. **Verify:** a second triage reported **HEALTHY, exit code 0**, and noted that the green run was on the drill branch, not `main`.

**One more real-world twist:** the supplied script authenticated with an Entra bearer token, and my personal-account Azure DevOps organization rejected it with **HTTP 403** on every endpoint. I kept the same read-only Build Logs API but routed it through the Azure DevOps CLI's own sign-in (`az devops invoke --http-method GET`), so the script never touches a token at all.

---

## What I'd tell someone starting Week 10

1. **Get a self-hosted agent with a fixed IP early.** It makes every firewall rule simple and every SSH failure easier to reason about.
2. **Verify on the server, not just in the pipeline UI.** The world-writable files and the TLS gap were both invisible in a green run.
3. **Treat secrets as a design decision, not an afterthought.** Service connections, Secure Files and secret variable groups each have a clear job. Use them so nothing sensitive ever lands in Git or YAML.
4. **Read the line before the error.** A missing digit in an IP and a dropped pair of quotes both announced themselves one line earlier.
5. **Keep AI on the read-only side of production.** Let it turn thousands of log lines into a focused, evidence-backed diagnosis. Keep the authority to change and deploy with a human.
6. **Clean up.** Every assignment ended with `terraform destroy` or deleting the resource group. Cloud bills don't care that it was "just a lab".

---

*This post is part of the DevOps Micro Internship (DMI) — Self-Paced Engineer Track — by Pravin Mishra. My graded progress is public: https://dmi.pravinmishra.com/s/tarwatkarkuntal315.html · Start your DevOps journey: https://dmi.pravinmishra.com/?utm_source=student&utm_medium=blog&utm_campaign=self-paced*

**Code:** https://github.com/tarwatkarkuntal315/devops-micro-internship-pravinmishra/tree/main/week-10-azure-devops · https://github.com/tarwatkarkuntal315/infra-epicbook · https://github.com/tarwatkarkuntal315/theepicbook
