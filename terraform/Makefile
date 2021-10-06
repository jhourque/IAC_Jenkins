myip := $(shell curl -s ifconfig.me)

init:
	@TF_VAR_myip=${myip} ../.bin/terraform init

plan:
	@TF_VAR_myip=${myip} ../.bin/terraform plan -var-file=../terraform.tfvars

apply:
	@TF_VAR_myip=${myip} ../.bin/terraform apply -var-file=../terraform.tfvars

destroy:
	@TF_VAR_myip=${myip} ../.bin/terraform destroy -var-file=../terraform.tfvars

output:
	@TF_VAR_myip=${myip} ../.bin/terraform output -var-file=../terraform.tfvars

env:
	@env
