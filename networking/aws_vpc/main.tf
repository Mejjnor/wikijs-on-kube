terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-vpc" },
    lookup(var.tags, "vpc_tags", {})
  )
}

resource "aws_internet_gateway" "inet-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-vpc-igw" },
    lookup(var.tags, "internet_gateway_tags", {})
  )
}

resource "aws_route_table" "exit-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inet-gw.id
  }

  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-exit-route-table" },
    lookup(var.tags, "internet_gateway_route_table_tags", {})
  )
}

data "aws_availability_zones" "region-azs" {
  state = "available"
}

resource "aws_subnet" "isolated-subnets" {
  count = var.vpc_isolated_subnets_count != null ? var.vpc_isolated_subnets_count: length(data.aws_availability_zones.region-azs.names)

  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index * 3)
  availability_zone = data.aws_availability_zones.region-azs.names[count.index % length(data.aws_availability_zones.region-azs.names)]
  
  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-subnet-isolated-${count.index}" },
    lookup(var.tags, "isolated_subnet_tags", {})
  )
}

resource "aws_subnet" "private-subnets" {
  count = var.vpc_private_subnets_count != null ? var.vpc_private_subnets_count: length(data.aws_availability_zones.region-azs.names)

  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index * 3 + 1)
  availability_zone = data.aws_availability_zones.region-azs.names[count.index % length(data.aws_availability_zones.region-azs.names)]
  
  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-subnet-private-${count.index}" },
    lookup(var.tags, "private_subnet_tags", {})
  )
}

resource "aws_subnet" "public-subnets" {
  count = var.vpc_public_subnets_count != null ? var.vpc_public_subnets_count: length(data.aws_availability_zones.region-azs.names)

  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index * 3 + 2)
  availability_zone = data.aws_availability_zones.region-azs.names[count.index % length(data.aws_availability_zones.region-azs.names)]
  
  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-subnet-public-${count.index}" },
    lookup(var.tags, "public_subnet_tags", {})
  )
}

locals {
  nat_subnet_map = {
    for subnet in aws_subnet.public-subnets : subnet.availability_zone => subnet.id...
  }
}

resource "aws_eip" "nat-ips" {
  for_each = local.nat_subnet_map
  domain = "vpc"

  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-nat-eip-${each.key}" },
    lookup(var.tags, "nat_eip_tags", {})
  )
}

resource "aws_nat_gateway" "nat-gws" {
  for_each = local.nat_subnet_map
  
  allocation_id = aws_eip.nat-ips[each.key].id
  subnet_id = each.value[0]

  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-nat-gw-${each.key}" },
    lookup(var.tags, "nat_gateway_tags", {})
  )
}

resource "aws_route_table" "nat-exit-rts" {
  vpc_id = aws_vpc.vpc.id
  for_each = local.nat_subnet_map

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gws[each.key].id
  }
  
  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-nat-exit-rtable-${each.key}" },
    lookup(var.tags, "nat_gateway_route_table_tags", {})
  )
}

resource "aws_route_table" "isolation-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    { Name = "${var.naming_prefix}-${var.env}-isolation-rtable" },
    lookup(var.tags, "isolation_route_table_tags", {})
  )
}

resource "aws_route_table_association" "nat-rt-associations" {
  count = length(aws_subnet.private-subnets)

  subnet_id = aws_subnet.private-subnets[count.index].id
  route_table_id = haskey(aws_route_table.nat-exit-rts, aws_subnet.private-subnets[count.index].availability_zone) ? (
                   aws_route_table.nat-exit-rts[aws_subnet.private-subnets[count.index].availability_zone].id) : (
                   aws_route_table.nat-exit-rts[keys(aws_route_table.nat-exit-rts)[0]].id)
}

resource "aws_route_table_association" "exit-rt-associations" {
  count = length(aws_subnet.public-subnets)

  subnet_id = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.exit-rt.id
}

resource "aws_route_table_association" "isolation-rt-associations" {
  count = length(aws_subnet.isolated-subnets)

  subnet_id = aws_subnet.isolated-subnets[count.index].id
  route_table_id = aws_route_table.isolation-rt.id
}

