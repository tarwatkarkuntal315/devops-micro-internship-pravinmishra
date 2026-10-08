# Runs the playbook from a Docker-based Ansible controller on Windows.
# Usage (from this folder):  .\run-ansible.ps1            -> ansible-playbook site.yml
#                            .\run-ansible.ps1 --check    -> extra args are passed through
# The deployment password is read from a file OUTSIDE the repository and passed to the
# container as an environment variable, so it never appears in Git, YAML or the command line.
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$passwordFile = "$HOME\.ssh\dmi-a03-deployer-password.txt"

if (-not (Test-Path $passwordFile)) { throw "Missing $passwordFile - create it with a 16+ character password first." }
$env:DEPLOY_PASSWORD = (Get-Content $passwordFile -Raw).Trim()

docker build -q -t dmi-ansible-a03:latest "$here\controller" | Out-Null

# Keys are mounted read-only and copied with 600 permissions inside the container,
# because Windows bind mounts appear world-readable and ssh would refuse them.
# The project is copied to /tmp/work because Ansible ignores ansible.cfg in a world-writable directory.
$inner = 'mkdir -p /root/.ssh && cp /keys/dmi-ec2-admin /root/.ssh/ && chmod 600 /root/.ssh/dmi-ec2-admin && cp -r /src /tmp/work && cd /tmp/work && ansible --version | head -1 && ansible-playbook site.yml "$@"'

try {
    docker run --rm -t `
      -e DEPLOY_PASSWORD `
      -v "${here}:/src:ro" `
      -v "$HOME\.ssh:/keys:ro" `
      dmi-ansible-a03:latest bash -c $inner ansible @args
}
finally {
    Remove-Item Env:\DEPLOY_PASSWORD -ErrorAction SilentlyContinue
}
