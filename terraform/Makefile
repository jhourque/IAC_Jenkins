myip := $(shell curl -s ifconfig.me)

init:
	@TF_VAR_myip=${myip} ../.bin/terraform init

plan:
	@TF_VAR_myip=${myip} ../.bin/terraform plan

apply:
	@TF_VAR_myip=${myip} ../.bin/terraform apply

destroy:
	@TF_VAR_myip=${myip} ../.bin/terraform destroy

get_password:
	@ip=$$(../.bin/terraform output jenkins_ip); \
	ssh -i ~/.ssh/id_rsa.iac ec2-user@$${ip} 'sudo cat /var/lib/jenkins/adminpassword.txt; echo'

env:
	@env
