terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89"
    }
  }

  required_version = ">= 1.2.0"
}

module "vpc" {
  source = "./networking/vpc"
  env = var.env
  naming_prefix = var.naming_prefix
  vpc_cidr_block = var.vpc_cidr_block
  vpc_public_subnets_count = var.vpc_public_subnets_count
  vpc_private_subnets_count = var.vpc_private_subnets_count
  vpc_isolated_subnets_count = var.vpc_isolated_subnets_count
  tags = {
    private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
    public_subnet_tags = { "kubernetes.io/role/elb" = "1" }
  }
}