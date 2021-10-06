variable "hosted_zone_name" {
  description = "Hosted zone for certificate and domain registration"
  type        = string
}

variable "subnet_id" {
  description = "Subnet identifier for EC2 deployment"
  type        = string
}

variable "public_ip" {
  description = "Set to true if you would like to have a public IP for instance"
  type        = bool
  default     = false
}

variable "static_ip" {
  description = "Set to true if you would like to have an AWS Elastic IP for instance"
  type        = bool
  default     = false
}
