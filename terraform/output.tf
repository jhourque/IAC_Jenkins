output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_ssh" {
  value = "ssh -i ~/.ssh/id_rsa.iac ec2-user@${aws_instance.jenkins.public_ip}"
}
