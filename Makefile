init:
	@rm -f ~/.ssh/id_rsa.iac
	@ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa.iac
	@rm -rf .bin
	@mkdir .bin
	@wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip -O .bin/terraform.zip
	@wget https://releases.hashicorp.com/packer/1.6.0/packer_1.6.0_linux_amd64.zip -O .bin/packer.zip
	@unzip .bin/terraform.zip -d .bin
	@unzip .bin/packer.zip -d .bin

.PHONY: packer terraform

packer:
	@cd packer; make build

terraform:
	@cd terraform; make init apply
