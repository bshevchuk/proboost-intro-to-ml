resource "random_integer" "network_num" {
  min = 10
  max = 50
  keepers = {
    environment = var.environment
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = local.config.vpc_name
  cidr = local.config.vpc_cidr

  azs              = local.config.azs
  private_subnets  = [for k, v in local.config.azs : cidrsubnet(local.config.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in local.config.azs : cidrsubnet(local.config.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.config.azs : cidrsubnet(local.config.vpc_cidr, 8, k + 8)]


  enable_nat_gateway      = false # not sure we need NAT GW in our case
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = false

  create_database_subnet_group = true

}
