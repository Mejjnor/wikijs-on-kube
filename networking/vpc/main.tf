terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "wok_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_internet_gateway" "wok_igw" {
  vpc_id = aws_vpc.wok_vpc.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
