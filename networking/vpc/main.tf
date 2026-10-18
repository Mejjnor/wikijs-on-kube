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

  tags = {
    Name = "wok-vpc"
  }
}

resource "aws_internet_gateway" "wok_igw" {
  vpc_id = aws_vpc.wok_vpc.id

  tags = {
    Name = "wok-vpc-igw"
  }
}

resource "aws_route_table" "wok_exit-rt" {
  vpc_id = aws_vpc.wok_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wok_igw.id
  }

  tags = {
    Name = "wok-exit-route-table"
  }
}

data "aws_availability_zones" "wok_azs" {
  state = "available"
}

resource "aws_subnet" "wok-private-subnets" {
  count = var.vpc_subnets_count != null ? var.vpc_subnets_count: length(data.aws_availability_zones.wok_azs.names)

  vpc_id = aws_vpc.wok_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index * 2)
  availability_zone = data.aws_availability_zones.wok_azs.names[count.index % length(data.aws_availability_zones.wok_azs.names)]
  
  tags = {
    Name = "wok-subnet-private-${count.index}"
  }
}

resource "aws_subnet" "wok-public-subnets" {
  count = var.vpc_subnets_count != null ? var.vpc_subnets_count: length(data.aws_availability_zones.wok_azs.names)

  vpc_id = aws_vpc.wok_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index * 2 + 1)
  availability_zone = data.aws_availability_zones.wok_azs.names[count.index % length(data.aws_availability_zones.wok_azs.names)]
  
  tags = {
    Name = "wok-subnet-public-${count.index}"
  }
}

locals {
  nat_subnet_map = {
    for subnet in aws_subnet.wok-public-subnets : subnet.availability_zone => subnet.id...
  }
}

resource "aws_eip" "wok_nat_ips" {
  for_each = local.nat_subnet_map
  domain = "vpc"

  tags = {
    Name = "wok-nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "wok_natgws" {
  for_each = local.nat_subnet_map
  
  allocation_id = aws_eip.wok_nat_ips[each.key].id
  subnet_id = each.value[0]

  tags = {
    Name = "wok-nat-gw-${each.key}"
  }
}

resource "aws_route_table" "wok-nat-exit-rts" {
  vpc_id = aws_vpc.wok_vpc.id
  for_each = local.nat_subnet_map

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wok_natgws[each.key].id
  }
  
  tags = {
    Name = "wok-subnet-private-${count.index}"
  }
}
