# Minimal Ansible controller image — Ansible does not run natively on Windows.
# passlib provides password_hash() for the deployment user's password.
FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-client \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir "ansible-core>=2.17,<2.19" passlib \
 && ansible-galaxy collection install ansible.posix

WORKDIR /work
