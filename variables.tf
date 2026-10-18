variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}

variable "vpc_subnets_count" {
  type = number
  default = 1
}

