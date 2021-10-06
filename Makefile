setup-binaries:
	@rm -rf .bin
	@mkdir .bin
	@wget https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip -O .bin/terraform.zip
	@wget https://releases.hashicorp.com/packer/1.7.0/packer_1.7.0_linux_amd64.zip -O .bin/packer.zip
	@unzip .bin/terraform.zip -d .bin
	@unzip .bin/packer.zip -d .bin

.PHONY: packer terraform

packer:
	@cd packer; make build

terraform:
	@cd terraform; make init apply

setup-packer-vpc:
	@cd packer-vpc; ../.bin/terraform init; ../.bin/terraform apply -auto-approve

teardown-packer-vpc:
	@cd packer-vpc; ../.bin/terraform init; ../.bin/terraform destroy -auto-approve
