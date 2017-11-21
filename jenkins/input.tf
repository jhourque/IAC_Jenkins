variable "vpc_id" {
  type    = "string"
}
variable "subnet_id" {
  type    = "string"
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
