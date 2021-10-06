data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

resource "aws_subnet" "subnet" {
  count = length(var.subnet_cidr_list)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnet_cidr_list, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = merge(
    {
      "Name" = format(
        "%s-%s-%s-%s",
        var.subnet_name,
        element(var.subnet_cidr_list, count.index),
        var.subnet_suffix,
        element(data.aws_availability_zones.available.names, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

resource "aws_route_table" "subnet" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.subnet_suffix)
    },
    var.tags,
  )
}

resource "aws_route" "subnet" {
  route_table_id         = aws_route_table.subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "subnet" {
  count = length(var.subnet_cidr_list)

  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = aws_route_table.subnet.id
}

