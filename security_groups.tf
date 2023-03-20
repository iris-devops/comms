##################################################################################
# SECURITY GROUPS #
##################################################################################

# Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.reach-vpc.id
  tags = merge(local.common_tags, {Product = "reach-sg" })
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for Elastic Load Balancer
resource "aws_security_group" "reach-sg-lb" {
  name   = local.reach-sg-lb
  vpc_id = aws_vpc.reach-vpc.id
  tags = merge(local.common_tags, {Product = "reach-sg" })
  # HTTP access from anywhere
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "reach-sg-lb-win" {
  name   = local.reach-sg-lb-win
  vpc_id = aws_vpc.reach-vpc.id
  tags = merge(local.common_tags, {Product = "reach-sg" })
  # HTTP access from anywhere
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.network_address_space[terraform.workspace]]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



# Nginx security group 
resource "aws_security_group" "reach-sg-web" {
  name   = local.reach-sg-web
  vpc_id = aws_vpc.reach-vpc.id
  tags = merge(local.common_tags, {Product = "reach-sg" })

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP access from VPC
  ingress {
    from_port = var.http_port
    to_port   = var.http_port
    protocol  = "tcp"
    # cidr_blocks = [var.network_address_space[terraform.workspace]]
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [var.network_address_space[terraform.workspace]]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# Nginx security group 
resource "aws_security_group" "reach-sg-db" {
  name   = local.reach-sg-db
  vpc_id = aws_vpc.reach-vpc.id
  tags = merge(local.common_tags, {Product = "reach-sg" })

  # SSH access from anywhere
  ingress {
    from_port   = var.aurora_db_port
    to_port     = var.aurora_db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDP Sec Group
resource "aws_security_group" "reach-sg-rdp" {
  name   = local.reach-sg-rdp
  vpc_id = aws_vpc.reach-vpc.id
  tags = merge(local.common_tags, {Product = "reach-sg" })

  # SSH access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
