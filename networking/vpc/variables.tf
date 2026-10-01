variable "vpc_cidr_block" {
  description = "Main private CIDR block for the VPC."
  type = string
}

variable "vpc_azs_list" {
  description = "List of Availability Zones for the VPC to work with. Defaults to all AZs in the working region."
  type = map
}

variable "vpc_subnets_count" {
  description = "Number of subnets to create and work in. Defaults to one per AZ. (Will create both a private and a public subnet times the count)"
  type = number
}