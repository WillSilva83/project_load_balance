
## VPC 
resource "aws_vpc" "vpc_main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "vpc_instance_test"
    Env  = "DEV"
  }

}

## SUBNETS 
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "subnet-a-terraform"
  }

}
resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "sa-east-1b"

  tags = {
    Name = "subnet-b-terraform"
  }
}


## INTERNET GATEWAY 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "terraform-igw"
  }
}

## ROUTE TABLE 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-terraform"
  }

}

## ROUTE TABLE ASSOCIATION 
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}