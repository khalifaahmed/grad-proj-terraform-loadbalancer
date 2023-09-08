resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  #Enable dns 
  enable_dns_hostnames = true
  enable_dns_support   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name}_igw"
  }
}
