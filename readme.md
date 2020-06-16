# Infrastructure as Code Labs

Terraform & Packer used to deploy Jenkins instance in AWS.

## Getting started

* Init config

```sh
make init
```

* Set AWS credentials

```sh
export AWS_ACCESS_KEY_ID="<your access key>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
export AWS_DEFAULT_REGION="<region>"
```

Tag subnet and vpc with tag: Packer = yes
Create SG named sg_packer (tag name)

* build AMI with packer

## Configure AMI with packer in ami_jenkins

```sh
make packer
```

## Deploy Jenkins

```sh
make terraform
```
answer yes to terraform apply cmd

## get admin password
```sh
cd terraform
make get_password
```
