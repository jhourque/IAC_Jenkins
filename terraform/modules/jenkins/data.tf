data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ami_jenkins" {
  name = "/project/jenkins/ami"
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}

data "aws_route53_zone" "primary" {
  name = var.hosted_zone_name
}
