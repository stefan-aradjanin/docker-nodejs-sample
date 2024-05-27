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

output "subnets" {
  value = module.subnet_addrs.network_cidr_blocks
}
