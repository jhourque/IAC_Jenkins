provider "aws" {
  region = "eu-west-1"
  allowed_account_ids = [var.allowed_account_id]
}

module "jenkins" {
  source           = "./modules/jenkins"
  subnet_id        = var.subnet_id == null ? module.vpc[0].subnet_ids[0] : var.subnet_id
  hosted_zone_name = var.hosted_zone_name
  public_ip        = true
  static_ip        = true
}

module "vpc" {
  source = "./modules/vpc"
  count  = var.subnet_id == null ? 1 : 0

  name             = "Automation"
  subnet_name      = "Automation"
  cidr             = "10.0.0.0/16"
  subnet_cidr_list = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  subnet_suffix    = "Public"
}
