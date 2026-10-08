output "instance_id" {
  value = aws_instance.web.id
}

output "ami_name" {
  value = data.aws_ami.ubuntu.name
}

output "public_ip" {
  description = "Target EC2 public IP used by Ansible, the SSH service connection and the browser"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "ssh_admin_command" {
  value = "ssh -i ~/.ssh/dmi-ec2-admin ubuntu@${aws_instance.web.public_ip}"
}
