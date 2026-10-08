# Runs the playbook from a Docker-based Ansible controller on Windows.
# Usage (from this folder):  .\run-ansible.ps1            -> ansible-playbook site.yml
#                            .\run-ansible.ps1 --check    -> extra args are passed through
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

docker build -q -t dmi-ansible:latest "$here\controller" | Out-Null

# Keys are mounted read-only and copied with 600 permissions inside the container,
# because Windows bind mounts appear world-readable and ssh would refuse them.
# The project is copied to /tmp/work because Ansible ignores ansible.cfg in a world-writable directory.
$inner = 'mkdir -p /root/.ssh && cp /keys/dmi-ec2-admin /keys/dmi-ec2-deploy.pub /root/.ssh/ && chmod 600 /root/.ssh/dmi-ec2-admin && cp -r /src /tmp/work && cd /tmp/work && ansible --version | head -1 && ansible-playbook site.yml "$@"'

docker run --rm -t `
  -v "${here}:/src:ro" `
  -v "$HOME\.ssh:/keys:ro" `
  dmi-ansible:latest bash -c $inner ansible @args
