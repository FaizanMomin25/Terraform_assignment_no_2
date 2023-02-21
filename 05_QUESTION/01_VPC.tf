# Create the VPC

resource "aws_vpc" "ethix-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create the public subnets

resource "aws_subnet" "ethix_public01" {
  vpc_id                  = aws_vpc.ethix-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ethix_public01"
  }
}
resource "aws_subnet" "ethix_public02" {
  vpc_id                  = aws_vpc.ethix-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ethix_public02"
  }
}

# Create the private subnets

resource "aws_subnet" "ethix_private01" {
  vpc_id            = aws_vpc.ethix-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "ethix_private01"
  }
}
resource "aws_subnet" "ethix_private02" {
  vpc_id            = aws_vpc.ethix-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "ethix_private02"
  }
}

# Create the Internet Gateway

resource "aws_internet_gateway" "ethix_igw" {
  vpc_id = aws_vpc.ethix-vpc.id
}

# Create an Elastic IP for the NAT Gateway

resource "aws_eip" "ethix_nat_eip" {
  vpc = true
}

# Create the NAT Gateway

resource "aws_nat_gateway" "ethix_nat_gateway" {
  allocation_id = aws_eip.ethix_nat_eip.id
  subnet_id     = aws_subnet.ethix_public01.id
}

#creating route tables

resource "aws_route_table" "ethix_pub_rt" {
  vpc_id = aws_vpc.ethix-vpc.id

  tags = {
    Name = "clouethix-public-route-table"
  }
}

resource "aws_route_table" "ethix_pri_rt" {
  vpc_id = aws_vpc.ethix-vpc.id

  tags = {
    Name = "clouethix-private-route-table"
  }
}

#creating routes

resource "aws_route" "ethix_igroute" {
  route_table_id         = aws_route_table.ethix_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ethix_igw.id
}

resource "aws_route" "ethix_ngroute" {
  route_table_id         = aws_route_table.ethix_pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.ethix_nat_gateway.id
}

#creating route table association

resource "aws_route_table_association" "ethix_pub_rt_ass" {
  subnet_id      = aws_subnet.ethix_public01.id
  route_table_id = aws_route_table.ethix_pub_rt.id
}

resource "aws_route_table_association" "ethix_pri-rt-ass" {
  subnet_id      = aws_subnet.ethix_private01.id
  route_table_id = aws_route_table.ethix_pri_rt.id
}
