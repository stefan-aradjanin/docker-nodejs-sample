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
