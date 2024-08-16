### resource "PROVIDER_TYPE" "NAME"{
#   CONFIG
#}

provider "aws" {
  region = "sa-east-1"
}

## VPC 

resource "aws_vpc" "vpc_instance" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "vpc_instance_test"
    Env  = "DEV"
  }

}

## SUBNET 
resource "aws_subnet" "vpc_subnet_instance" {
  vpc_id            = aws_vpc.vpc_instance.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "SUBNET_DEV_INSTANCE"
  }

}

## INTERFACE 

resource "aws_network_interface" "vpc_network_instance" {
  subnet_id   = aws_subnet.vpc_subnet_instance.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "NETWORK_INTERFACE_DEV_INSTANCE"
  }

}

## SECURITY GROUP 

resource "aws_security_group" "security_group_instance" {
  name = "terraform-example-instance"

  ingress {
    from_port  = 8080
    to_port    = 8080
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "instance_micro" {
  ami                    = "ami-09523541dfaa61c85"
  instance_type          = "t1.micro"
  vpc_security_group_ids = ["${aws_security_group.security_group_instance.id}"]

  network_interface {
    network_interface_id = aws_network_interface.vpc_network_instance.id
    device_index         = 0
  }

  user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p 8080 &
  EOF

  tags = {
    Name = "INSTANCE_DEV_TERRAFORM"
  }



}

