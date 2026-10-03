# Assignment 7 â€” Kubernetes Services (ClusterIP)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this guided lab, you will create an internal ClusterIP Service for NGINX, call it by DNS and virtual IP, break and fix its selector, and prove readiness-aware endpoint routing.

---

# Task 1 â€” Deploy the Probed NGINX Workload

## Goal

Create two healthy, labeled NGINX Pods (readiness + liveness probes) as Service backends.

### Evidence

#### Screenshot 1 â€” Two Ready Pods with labels and IPs

![Screenshot 1 â€” Two Ready Pods with labels and IPs](screenshots/assignment-07/week-12-assignment-07-screenshot-01-pods.png)

---

# Task 2 â€” Create and Inspect the ClusterIP Service

## Goal

Create `nginx-svc` (type `ClusterIP`, selector `app: nginx`, port 80) and inspect the Service, Endpoints, and EndpointSlices.

### Evidence

#### Screenshot 2 â€” Service ClusterIP plus populated Endpoints and EndpointSlices

![Screenshot 2 â€” Service ClusterIP, Endpoints and EndpointSlice](screenshots/assignment-07/week-12-assignment-07-screenshot-02-service-endpoints.png)

---

# Task 3 â€” Call the Service from a Client Pod

## Goal

Create a BusyBox `tester` Pod and call `nginx-svc` by short name, ClusterIP, and both short/FQDN via `nslookup`.

### Evidence

#### Screenshot 3 â€” Successful `wget` responses and `nslookup` output

![Screenshot 3 â€” Service DNS, ClusterIP access and FQDN resolution](screenshots/assignment-07/week-12-assignment-07-screenshot-03-service-dns.png)

---

# Task 4 â€” Break and Fix the Selector Contract

## Goal

Change the Service selector to `app: does-not-match`, confirm endpoints become empty and requests fail, then restore `app: nginx`.

### Evidence

#### Screenshot 4 â€” Empty endpoints during failure and restored endpoints after the fix

![Screenshot 4 â€” Selector failure and restored Service routing](screenshots/assignment-07/week-12-assignment-07-screenshot-04-selector-break-fix.png)

The broken selector produced no Service endpoints and requests to the ClusterIP failed with `Connection refused`. Restoring the `app: nginx` selector repopulated the endpoints and restored successful NGINX responses.

---

# Task 5 â€” Prove Readiness-Aware Routing

## Goal

Scale to one replica, apply a broken readiness patch, confirm the NotReady Pod is excluded from Service endpoints, then restore the healthy Deployment.

### Evidence

#### Screenshot 5 â€” NotReady Pod with excluded endpoint, followed by restored endpoint membership

![Screenshot 5 â€” Readiness failure and endpoint exclusion](screenshots/assignment-07/week-12-assignment-07-screenshot-05-readiness-routing.png)

The intentionally broken readiness probe used `/does-not-exist`, causing HTTP 404 readiness failures. The affected Pod became `Ready: False`, and its IP appeared under `NotReadyAddresses` instead of the ready endpoint list. The healthy Deployment was then restored.

---

# Task 6 â€” Troubleshoot and Optionally Clean Up

## Goal

Verify the Service path, then optionally delete `tester` and `nginx-svc`.

### Evidence

#### Screenshot 6 â€” Final verification or optional cleanup output

![Screenshot 6 â€” Final healthy Service verification](screenshots/assignment-07/week-12-assignment-07-screenshot-06-final-verification.png)

Final verification showed two Ready NGINX Pods, a ClusterIP Service, populated Endpoints and EndpointSlice records, and successful Service access from the `tester` Pod.

---

### Notes


This lab demonstrated how a Kubernetes ClusterIP Service provides stable internal discovery while Pod IPs remain ephemeral.

The `app: nginx` label and Service selector formed the Service-to-Pod contract. When the selector was intentionally changed to `app: does-not-match`, the Service had no endpoints and requests failed. Restoring the selector immediately restored endpoint membership and routing.

The lab also demonstrated readiness-aware routing. When the readiness probe was intentionally changed to `/does-not-exist`, the affected Pod became NotReady and its IP was excluded from the ready endpoint addresses. Restoring the healthy Deployment returned the Service to two healthy NGINX backends.

---

# Submission Instructions

- Add all required screenshots in your submission
- Include the completed YAML manifests used in the lab

---

# Completion Checklist

- [x] Task 1: Probed NGINX Deployment applied (Screenshot 1)
- [x] Task 2: ClusterIP Service created and inspected (Screenshot 2)
- [x] Task 3: Service reached by DNS and ClusterIP (Screenshot 3)
- [x] Task 4: Selector broken and fixed (Screenshot 4)
- [x] Task 5: Readiness-aware routing proven (Screenshot 5)
- [x] Task 6: Verified / cleaned up (Screenshot 6)
- [x] Reflection notes written (Notes)

---

## ðŸ“Œ About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## ðŸ“Œ Resources

- ðŸŒ DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- ðŸŽ“ University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- ðŸ’¬ Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- ðŸ“ Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- â–¶ï¸ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- ðŸ”— Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- ðŸ¢ CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 â€” Agentic AI Track.*
