variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}

variable "env" {
  description = "Current deployment environment tier"
  type = string
  default = "dev"
}

variable "naming_prefix" {
  description = "Prefix to attach to the AWS resource names"
  type = string
  default = "main"
}

variable "vpc_public_subnets_count" {
  type = number
  default = 1
}

variable "vpc_private_subnets_count" {
  type = number
  default = 1
}

variable "vpc_isolated_subnets_count" {
  type = number
  default = 0
}

