data "aws_subnet" "subnet" {
  id = var.subnet_id
}

data "aws_route53_zone" "primary" {
  name = var.hosted_zone_name
}
