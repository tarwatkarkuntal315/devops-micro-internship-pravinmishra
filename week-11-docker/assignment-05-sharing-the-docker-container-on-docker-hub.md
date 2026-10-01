# Assignment 5 — Sharing the Docker Container on Docker Hub

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will publish a Dockerized React application to Docker Hub, then pull and run it to verify it can be downloaded and executed from another system.

---

# Task 1 — Publish a Docker Image to Docker Hub

## Goal

Create a Docker Hub repository (`my-react-app`), log in from the CLI, tag and push your local image, verify it on Docker Hub, then pull and run it to confirm the application is accessible.

### Evidence

#### Screenshot 1 — Docker Hub repository (`my-react-app`)

![Screenshot 1 — Docker Hub repository](screenshots/assignment-05/week-11-assignment-05-screenshot-01-dockerhub-repository.png)

---

#### Screenshot 2 — Successful `docker login`

```powershell
echo "Full Name: Kuntal Tarwatkar"
docker login --username kuntal210790
```

Result:

```text
Login Succeeded
```

![Screenshot 2 — Docker login](screenshots/assignment-05/week-11-assignment-05-screenshot-02-docker-login.png)

---

#### Screenshot 3 — Successful `docker tag`

The existing React image was tagged for the Docker Hub repository:

```powershell
docker tag react-multistage:latest kuntal210790/my-react-app:latest
echo "Full Name: Kuntal Tarwatkar"
docker image ls kuntal210790/my-react-app
```

The resulting image tag was:

```text
kuntal210790/my-react-app:latest
```

Image ID:

```text
d4c03e401960
```

![Screenshot 3 — Docker image tag](screenshots/assignment-05/week-11-assignment-05-screenshot-03-docker-image-tag.png)

---

#### Screenshot 4 — Successful `docker push`

The tagged image was pushed to Docker Hub:

```powershell
docker push kuntal210790/my-react-app:latest
```

The push completed successfully.

![Screenshot 4 — Docker push](screenshots/assignment-05/week-11-assignment-05-screenshot-04-docker-push.png)

---

#### Screenshot 5 — Docker Hub repository showing the uploaded image

The Docker Hub repository was refreshed and verified to contain the uploaded `latest` image tag.

![Screenshot 5 — Docker Hub latest tag](screenshots/assignment-05/week-11-assignment-05-screenshot-05-dockerhub-latest-tag.png)

---

#### Screenshot 6 — Successful `docker pull`

The targeted local image tags were removed:

```powershell
docker rm -f react-container react-prod 2>$null
docker image rm react-multistage:latest kuntal210790/my-react-app:latest
```

The image was then downloaded again from Docker Hub:

```powershell
echo "Full Name: Kuntal Tarwatkar"
docker pull kuntal210790/my-react-app:latest
docker image ls kuntal210790/my-react-app
```

The image was successfully pulled and appeared locally as:

```text
kuntal210790/my-react-app:latest
```

![Screenshot 6 — Docker pull](screenshots/assignment-05/week-11-assignment-05-screenshot-06-docker-pull.png)

---

#### Screenshot 7 — Output of `docker ps`

The previous Assignment 04 containers were removed from the Azure VM. The Docker Hub image was then pulled and run on the VM.

```bash
docker run -d \
  --name react-container \
  -p 80:80 \
  kuntal210790/my-react-app:latest

echo "Full Name: Kuntal Tarwatkar"
docker ps
```

The running container showed:

```text
Image: kuntal210790/my-react-app:latest
Status: Up
Port: 0.0.0.0:80->80/tcp
Name: react-container
```

![Screenshot 7 — Docker container running on Azure VM](screenshots/assignment-05/week-11-assignment-05-screenshot-07-docker-container-running-vm.png)

---

#### Screenshot 8 — Browser displaying the running React application

The published Docker image was accessed through the Azure VM public IP:

```text
http://4.224.18.235
```

The React application loaded successfully.

![Screenshot 8 — React application](screenshots/assignment-05/week-11-assignment-05-screenshot-08-react-application.png)

---

# LinkedIn Post (Optional)

## Goal

Create a LinkedIn post covering the assignment title, the Docker Hub repository created, steps performed, key learning outcomes, and a screenshot of the published image.

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

https://www.linkedin.com/feed/update/urn:li:activity:7511444244184825857/

---

#### Screenshot — Published LinkedIn post

![Published LinkedIn Post](screenshots/assignment-05/week-11-assignment-05-linkedin-post.png)

---

# Submission Instructions

- Add all required screenshots in your submission
- Include the Docker Hub repository URL
- Full name must be visible in required screenshots
- Do not expose passwords or sensitive credentials

---

# Completion Checklist

- [x] Docker Hub account and repository created
- [x] Docker image tagged and pushed successfully (Screenshots 1–5)
- [x] Docker image pulled and container run successfully (Screenshots 6–7)
- [x] React application accessible in the browser (Screenshot 8)
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
