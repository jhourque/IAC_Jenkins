variable "myip" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Packer"
    values = ["yes"]
  }
}

data "aws_subnet" "subnet" {
  filter {
    name   = "tag:Packer"
    values = ["yes"]
  }
}

provider "aws" {
}

# terraform {
#   backend "s3" {
#     bucket = "iac-tfstate"
#     key    = "jenkins/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }
