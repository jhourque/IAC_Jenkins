data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Packer" = "yes"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    "Packer" = "yes"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "subnet" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "subnet" {
  route_table_id         = aws_route_table.subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.subnet.id
}
