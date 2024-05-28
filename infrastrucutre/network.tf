module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.base_cidr_block
  networks = [
    {
      name     = "private-eu-central-1a"
      new_bits = 2
    },
    {
      name     = "private-eu-central-1b"
      new_bits = 2
    },
    {
      name     = "private-eu-central-1c"
      new_bits = 2
    },
    {
      name     = "public-eu-central-1a"
      new_bits = 8
    },
    {
      name     = "public-eu-central-1b"
      new_bits = 8
    },
    {
      name     = "public-eu-central-1c"
      new_bits = 8
    },
    {
      name     = "database-eu-central-1a"
      new_bits = 8
    },
    {
      name     = "database-eu-central-1b"
      new_bits = 8
    },
    {
      name     = "database-eu-central-1c"
      new_bits = 8
    }
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vega-course-tf-vpc"
  cidr = module.subnet_addrs.base_cidr_block

  azs = data.aws_availability_zones.available.names

  public_subnets = [
    lookup(module.subnet_addrs.network_cidr_blocks, "public-eu-central-1a", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "public-eu-central-1b", "what?"),
  lookup(module.subnet_addrs.network_cidr_blocks, "public-eu-central-1c", "what?")]

  private_subnets = [
    lookup(module.subnet_addrs.network_cidr_blocks, "private-eu-central-1a", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "private-eu-central-1b", "what?"),
  lookup(module.subnet_addrs.network_cidr_blocks, "private-eu-central-1c", "what?")]

  database_subnets = [
    lookup(module.subnet_addrs.network_cidr_blocks, "database-eu-central-1a", "what?"),
    lookup(module.subnet_addrs.network_cidr_blocks, "database-eu-central-1b", "what?"),
  lookup(module.subnet_addrs.network_cidr_blocks, "database-eu-central-1c", "what?")]

  #nat gateway  
  enable_nat_gateway     = true
  one_nat_gateway_per_az = false
  single_nat_gateway     = true

  #internet gateway
  create_igw = true
}

