variable "vpc_cidr_block" {
  description = "Main private CIDR block for the VPC."
  type = string
  default = null
}

variable "vpc_azs_list" {
  description = "List of Availability Zones for the VPC to work with. Defaults to all AZs in the working region."
  type = list
  default = null
}

variable "vpc_public_subnets_count" {
  description = "Number of public subnets to create and work in. Defaults to one per region AZ."
  type = number
  default = null
}

variable "vpc_private_subnets_count" {
  description = "Number of private subnets to create and work in. Defaults to one per region AZ."
  type = number
  default = null
}

variable "vpc_isolated_subnets_count" {
  description = "Number of isolated subnets to create and work in. Defaults to one per region AZ."
  type = number
  default = null
}

variable "naming_prefix" {
  description = "Prefix to attach to the AWS resource names"
  type = string
  default = "main"
}

variable "env" {
  description = "Target deployment environment tier"
  type = string
  default = "dev"
}

variable "tags" {
  description = "Custom tags for the resources in the VPC block"
  type = map(map(string))
  default = {
    vpc_tags = {}
    internet_gateway_tags = {}
    internet_gateway_route_table_tags = {}
    isolated_subnet_tags = {}
    private_subnet_tags = {}
    public_subnet_tags = {}
    nat_eip_tags = {}
    nat_gateway_tags = {}
    nat_gateway_route_table_tags = {}
    isolation_route_table_tags = {}
  }
}
