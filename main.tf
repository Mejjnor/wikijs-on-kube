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
  vpc_cidr_block = var.vpc_cidr_block
  vpc_subnets_list = null
}