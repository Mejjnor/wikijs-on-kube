output "vpc_id" {
  description = "ID of project VPC"
  value = aws_vpc.vpc.id
}

output "isolated_subnet_ids" {
  description = "IDs of the isolated subnets in the vpc"
  value = aws_subnet.isolated-subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets in the vpc"
  value = aws_subnet.private-subnets[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in the vpc"
  value = aws_subnet.public-subnets[*].id
}
