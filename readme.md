# Infrastructure as Code Labs

Terraform & Packer used to deploy Jenkins instance in AWS.

## Getting started

* Install terraform

```sh
wget https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip -O /tmp/terraform.zip
cd /tmp
unzip /tmp/terraform.zip
sudo install /tmp/terraform /usr/bin
```

* Install packer

```sh
wget https://releases.hashicorp.com/packer/1.1.1/packer_1.1.1_linux_amd64.zip -O /tmp/packer.zip
cd /tmp
unzip /tmp/packer.zip
sudo install /tmp/packer /usr/bin
```

* Set ssh key for keypair

```sh
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa.iac
```

* Set AWS credentials, region, vpc_id & subnet_id to use

```sh
export AWS_ACCESS_KEY_ID="<your access key>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
export AWS_DEFAULT_REGION="<region>"
export VPC_ID="<vpc id>"
export SUBNET_ID="<subnet id>"
```

## Configure AMI with packer in ami_jenkins

```sh
packer validate ami_jenkins.json
packer build ami_jenkins.json
```

## Deploy Jenkins in jenkins

```sh
terraform init
terraform plan -var vpc_id=$VPC_ID -var subnet_id=$SUBNET_ID
terraform apply -var vpc_id=$VPC_ID -var subnet_id=$SUBNET_ID
```


## `Connect to Jenkins url (output of terraform) and activate Security`

* Warning (top red box) on first startup
![Unsecure](../master/img/unsecure.jpg)

* Enabling Security
![Enable Security](../master/img/secure1.jpg)

* Update admin account
![Update admin account](../master/img/manage_admin_user.jpg)

* Change admin password
![Set admin password](../master/img/set_admin_password.jpg)

* Back to security tab, only allow logged-in users
![Allow only logged-in users](../master/img/secure2.jpg)

