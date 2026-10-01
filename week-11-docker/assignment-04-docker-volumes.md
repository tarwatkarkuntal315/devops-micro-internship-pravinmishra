# Assignment 4 — Docker Volumes

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will learn how Docker Volumes and Bind Mounts provide persistent storage for containers, deploying applications that retain logs and data even after containers are stopped or removed.

---

# Task 1 — Deploy a Standalone Application with Persistent Logs Using Bind Mounts

## Goal

Run an Nginx container (`myweb`) with a Bind Mount from `~/nginx-logs` to `/var/log/nginx`, verify the site loads, confirm logs are written, remove the container, and confirm the logs persist on the host.

### Evidence

#### Screenshot 1 — Output of `docker images`

![Screenshot 01 — Docker pull nginx](screenshots/assignment-04/week-11-assignment-04-screenshot-01-docker-pull-nginx.png)

---

#### Screenshot 2 — Output of `docker search nginx`

![Screenshot 02 — Nginx logs directory](screenshots/assignment-04/week-11-assignment-04-screenshot-02-nginx-logs-directory.png)

---

#### Screenshot 3 — Successful `docker pull nginx` (if applicable)

![Screenshot 03 — myweb container](screenshots/assignment-04/week-11-assignment-04-screenshot-03-myweb-docker-ps.png)

---

#### Screenshot 4 — Creation of the `~/nginx-logs` directory

![Screenshot 04 — Nginx browser verification](screenshots/assignment-04/week-11-assignment-04-screenshot-04-nginx-browser.png)

---

#### Screenshot 5 — Output of `docker run` with the Bind Mount

![Screenshot 05 — Nginx host logs](screenshots/assignment-04/week-11-assignment-04-screenshot-05-nginx-log-files.png)

---

#### Screenshot 6 — Output of `docker ps` showing the running `myweb` container

![Screenshot 06 — Nginx container removal](screenshots/assignment-04/week-11-assignment-04-screenshot-06-myweb-container-removal.png)

---

#### Screenshot 7 — Browser displaying the Nginx Welcome Page

![Screenshot 07 — Persistent Nginx logs](screenshots/assignment-04/week-11-assignment-04-screenshot-07-persistent-nginx-logs.png)

---

#### Screenshot 8 — Output of `ls ~/nginx-logs` showing `access.log` and `error.log`

![Screenshot 08 — Project file structure](screenshots/assignment-04/week-11-assignment-04-screenshot-08-project-file-structure.png)

---

#### Screenshot 9 — Successful removal of the container

![Screenshot 09 — Docker network](screenshots/assignment-04/week-11-assignment-04-screenshot-09-docker-network-mynetwork.png)

---

#### Screenshot 10 — Output of `ls ~/nginx-logs` confirming the log files remain after the container has been removed

![Screenshot 10 — Docker volume](screenshots/assignment-04/week-11-assignment-04-screenshot-10-docker-volume-shared-data.png)

---

# Task 2 — Deploy Two Containers with Persistent Data Using Docker Volumes

## Goal

Create a custom network `mynetwork` and a Docker volume `shared-data`, build and run a `backend` container that writes to the shared volume and a `frontend` container that reads from it, and confirm updates are reflected immediately.

### Evidence

#### Screenshot 1 — Project folder structure

![Screenshot 11 — Backend Dockerfile](screenshots/assignment-04/week-11-assignment-04-screenshot-11-backend-dockerfile.png)

---

#### Screenshot 2 — Output of `docker network create mynetwork`

![Screenshot 12 — Backend image build](screenshots/assignment-04/week-11-assignment-04-screenshot-12-backend-image-build.png)

---

#### Screenshot 3 — Output of `docker volume create shared-data`

![Screenshot 13 — Backend container](screenshots/assignment-04/week-11-assignment-04-screenshot-13-backend-container.png)

---

#### Screenshot 4 — Backend Dockerfile

![Screenshot 14 — Frontend Dockerfile](screenshots/assignment-04/week-11-assignment-04-screenshot-14-frontend-dockerfile.png)

---

#### Screenshot 5 — Successful backend image build

![Screenshot 15 — Frontend image build](screenshots/assignment-04/week-11-assignment-04-screenshot-15-frontend-image-build.png)

---

#### Screenshot 6 — Frontend Dockerfile

![Screenshot 16 — Both containers running](screenshots/assignment-04/week-11-assignment-04-screenshot-16-both-containers-running.png)

---

#### Screenshot 7 — Successful frontend image build

![Screenshot 17 — Backend write operation](screenshots/assignment-04/week-11-assignment-04-screenshot-17-backend-write-operation.png)

---

#### Screenshot 8 — Output of `docker ps` showing both containers

![Screenshot 18 — Frontend reads backend data](screenshots/assignment-04/week-11-assignment-04-screenshot-18-frontend-hello-from-backend.png)

---

#### Screenshot 9 — Successful execution of `docker exec backend curl http://localhost/write`

![Screenshot 19 — Test Data 1](screenshots/assignment-04/week-11-assignment-04-screenshot-19-test-data-1.png)

---

#### Screenshot 10 — Browser displaying "Hello from Backend!"

![Screenshot 20 — Test Data 2](screenshots/assignment-04/week-11-assignment-04-screenshot-20-test-data-2-new-update.png)

---

#### Screenshot 11 — Browser displaying "Test Data 1" after the first update

![Screenshot 21 — Container removal](screenshots/assignment-04/week-11-assignment-04-screenshot-21-container-recreation.png)

---

#### Screenshot 12 — Browser displaying "Test Data 2 - New Update" after the second update

![Screenshot 22 — Containers recreated](screenshots/assignment-04/week-11-assignment-04-screenshot-22-containers-recreated.png)

---

After recreation, the public application was refreshed:

```text
http://4.224.18.235
```

The browser still displayed:

```text
Test Data 2 - New Update
```

### Persistence Evidence

![Screenshot 23 — Data after container recreation](screenshots/assignment-04/week-11-assignment-04-screenshot-23-data-after-recreation.png)

---

# LinkedIn Post (Optional)

## Goal

Create a LinkedIn post covering the assignment, Docker Hub repository, steps performed, and key learning outcomes.

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

https://www.linkedin.com/feed/update/urn:li:activity:7511432757550452738/

---

#### Screenshot — Published LinkedIn post

![LinkedIn Post — Docker Volumes and Bind Mounts](screenshots/assignment-04/week-11-assignment-04-docker-volumes-and-bind-mounts-linkedin.png)


---

# Submission Instructions

- Add all required screenshots in your submission
- Full name must be visible in required screenshots
- Do not expose sensitive information

---

# Completion Checklist

- [x] Task 1: Bind-mounted persistent logs verified before and after container removal (Screenshots 1–10)
- [x] Task 2: Docker volume shared between frontend and backend verified (Screenshots 1–12)
- [x] No sensitive information exposed

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
