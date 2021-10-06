variable "subnet_id" {
  description = "Subnet identifier to use for Jenkins instance deployment. When unspecified, a VPC will be deployed."
  type        = string
  default     = null
}

variable "hosted_zone_name" {
  description = "Hosted zone for certificate and domain registration"
  type        = string
}
