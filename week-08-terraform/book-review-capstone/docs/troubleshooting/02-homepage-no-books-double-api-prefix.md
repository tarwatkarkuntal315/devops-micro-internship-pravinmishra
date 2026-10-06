# Troubleshooting 02 — Home page shows "No books available"

Project: Book Review App capstone (AWS ap-south-1) · Student: Kuntal Tarwatkar · Date: 2026-10-06

## 1. Observe
After a successful apply, all 4 ALB targets were healthy and Register/Login worked
(navbar shows "Kuntal Tarwatkar | Logout"), but the home page showed "No books available."

## 2. Collect evidence
- `curl http://<public ALB>/api/books` -> **200**, 3 books (JSON). Backend, internal ALB, RDS all fine.
- Response carried `Access-Control-Allow-Origin: http://<public ALB>` -> CORS fine.
- Login/Register (POST through `/api`) succeeded -> Nginx `/api/` proxy fine.
- So only the home page's request was failing.

## 3. Identify the failing layer
Frontend code vs. Web-tier routing. Read the app source:
- `frontend/src/services/api.js` (login, register, book details, reviews): `${API_URL}/users/login` -> expects base URL **including** `/api`
- `frontend/src/app/page.js` (home page only): `${NEXT_PUBLIC_API_URL}/api/books` -> adds `/api` **itself**

## 4. Root cause
With `NEXT_PUBLIC_API_URL=http://<public ALB>/api`, the home page requests `/api/api/books`.
`curl http://<public ALB>/api/api/books` -> **404**. The upstream app is internally inconsistent,
so no single `NEXT_PUBLIC_API_URL` value works for every page.

## 5. One controlled fix (Web tier, infrastructure only — app source untouched)
`modules/compute/templates/web_user_data.sh.tftpl`, Nginx:
```
location /api/api/ {
    rewrite ^/api(/api/.*)$ $1 break;          # /api/api/books -> /api/books
    proxy_pass http://$internal_alb$uri$is_args$args;
}
```
No security group, port, or exposure change.

## 6. Verify before applying
`terraform validate` Success. Plan: `4 to add, 0 to change, 4 to destroy` —
only the 2 web EC2s + their target-group attachments are replaced (Nginx config is in their user data).

## 7. Retest
Human-approved apply -> wait for web targets healthy (Next.js rebuild ~10 min) ->
home page lists books; `/api/api/books` returns 200.
