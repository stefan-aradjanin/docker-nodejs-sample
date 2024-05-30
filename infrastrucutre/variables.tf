variable "base_cidr_block" {
  description = "The base CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "my_office_cidr" {
  description = "CIDR office address block"
  type        = string
  default     = "94.230.189.222/32"
}

variable "domain_name" {
  description = "A name for DNS"
  type        = string
  default     = "stefan-aradjanin.beta.devops.sitesstage.com"
}

variable "route_53_zone_name" {
  description = "Rotue 53 zone name"
  type        = string
  default     = "beta.devops.sitesstage.com"
}
