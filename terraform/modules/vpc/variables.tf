variable "name" {
  description = "VPC name"
}

variable "subnet_name" {
  description = "Subnet Name"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
}

variable "subnet_cidr_list" {
  description = "list of cidr for each AZ"
  type        = list(string)
}

variable "subnet_suffix" {
  description = "Subnet for subnet tag name (could be pub, priv, ...)"
}

variable "tags" {
  description = "Tags for all resources"
  default     = {}
}
