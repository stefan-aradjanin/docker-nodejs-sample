module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vega-course-tf-vpc"
  cidr = module.subnet_addrs.base_cidr_block

  azs = var.availability_zones

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


  tags = {
    # Name = "vega-course-tf-vpc"
  }
}

output "nat_gateway_ids" {
  value = module.vpc.private_nat_gateway_route_ids
}
