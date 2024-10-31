// --- VPC ---
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

// --- Internet Gateway ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

// --- Public Subnets ---
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets_map

  vpc_id = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, var.subnets_bit_length, each.value)
  map_public_ip_on_launch = true
  tags = {
    Name = format("Public subnet %s", each.value)
  }
}

// --- Private Subnets ---
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets_map

  vpc_id = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, var.subnets_bit_length, each.value)
  tags = {
    Name = format("Private subnet %s", each.value)
  }
}

// --- Routes ---
resource "aws_route_table" "public_subnet_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public Subnets Route Table"
  }
}
resource "aws_route" "vpc_internet_access" {
  route_table_id = aws_route_table.public_subnet_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_rtb_to_public_subnets" {
  for_each = { for public_subnet in aws_subnet.public_subnets : public_subnet.cidr_block => public_subnet.id }
  route_table_id = aws_route_table.public_subnet_rtb.id
  subnet_id = each.value
}
