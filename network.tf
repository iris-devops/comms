# NETWORKING #

#Public Route -> Internet Gateway
#Private Route -> Nat Gateway


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.reach-vpc.id
  tags   = merge(local.common_tags, { Product = "reach-igw" })
}

resource "aws_subnet" "subnet" {
  count                   = var.subnet_count[terraform.workspace]
  cidr_block              = cidrsubnet(var.network_address_space[terraform.workspace], 8, count.index)
  vpc_id                  = aws_vpc.reach-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = merge(local.common_tags, { Product = "reach-subnet" })
}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.reach-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_internet_gateway.igw.id
    nat_gateway_id = aws_nat_gateway.network-ntg-public.id
  }
  tags = merge(local.common_tags, { Product = "reach-rtb" })
}

resource "aws_route_table_association" "rta-subnet" {
  count          = var.subnet_count[terraform.workspace]
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rtb.id
}

//  resource "aws_db_subnet_group" "aurora_subnet_group" {
//   name       = local.rds_aurora_subgroup
//   subnet_ids = aws_subnet.subnet[*].id
//    tags       = merge(local.common_tags, { Product = "reach-subnet" })
//  }



######## Public Network 

resource "aws_eip" "network-eip-public" {
  # count = var.subnet_count[terraform.workspace]
  vpc   = true
  # network_interface         = aws_network_interface.multi-ip.id
  # associate_with_private_ip = "10.0.0.10"
    tags = {
    "Name" = "Public"
  }
}

resource "aws_subnet" "subnet-public" {
  # count                   = var.subnet_count[terraform.workspace]
  cidr_block              = cidrsubnet(var.network_address_space[terraform.workspace], 8, 4)
  vpc_id                  = aws_vpc.reach-vpc.id
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = merge(local.common_tags, { Product = "reach-subnet", "Name" = "Public" } )
}


resource "aws_nat_gateway" "network-ntg-public" {
  allocation_id = aws_eip.network-eip-public.id
  subnet_id     = aws_subnet.subnet-public.id
  depends_on    = [aws_eip.network-eip-public]
    tags = {
    "Name" = "Public"
  }
}

resource "aws_route_table" "network-rt-public" {
  vpc_id = aws_vpc.reach-vpc.id
  route = [
    {
      carrier_gateway_id         = ""
      cidr_block                 = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.igw.id
      instance_id                = ""
      ipv6_cidr_block            = null
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
      core_network_arn = null
    },
  ]
  depends_on = [aws_nat_gateway.network-ntg-public]
  tags = {
    "Name" = "Public"
  }
}


resource "aws_route_table_association" "network-rta-public" {
  subnet_id      = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.network-rt-public.id
}





###### EC2 subnet specificall to allow rdp access
resource "aws_subnet" "subnet-ec2" {
  # count                   = var.subnet_count[terraform.workspace]
  cidr_block              = cidrsubnet(var.network_address_space[terraform.workspace], 8, 5)
  vpc_id                  = aws_vpc.reach-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = merge(local.common_tags, { Product = "reach-subnet", "Name" = "Public" } )
}

# ROUTING #
resource "aws_route_table" "rtb-ec2" {
  vpc_id = aws_vpc.reach-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    # nat_gateway_id = aws_nat_gateway.network-ntg-public.id
  }
  tags = merge(local.common_tags, { Product = "reach-rtb" })
}

resource "aws_route_table_association" "rta-subnet-ec2" {
  # count          = var.subnet_count[terraform.workspace]
  subnet_id      = aws_subnet.subnet-ec2.id
  route_table_id = aws_route_table.rtb-ec2.id
}