resource "aws_vpc" "reach-vpc" {
  cidr_block           = var.network_address_space[terraform.workspace]
  enable_dns_hostnames = "true"
  tags = merge(local.common_tags, {Product = "reach-vpc" })
}
