### resource "PROVIDER_TYPE" "NAME"{
#   CONFIG
#}

provider "aws" {
  region = "sa-east-1"
}


## VARIABLES 

variable "server_port" {
  description = "A porta parao servidor que sera usada para request HTTP."
  default     = 8080
}

data "aws_availability_zones" "all" {

}

## VPC 
resource "aws_vpc" "vpc_instance" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "vpc_instance_test"
    Env  = "DEV"
  }

}

## SUBNETS 
resource "aws_subnet" "vpc_subnet_instance" {
  vpc_id            = aws_vpc.vpc_instance.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "SUBNET_DEV_INSTANCE"
  }

}
resource "aws_subnet" "subnet_ebl" {
  vpc_id            = aws_vpc.vpc_instance.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "SUBNET_DEV_ELB"
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

## SECURITYS GROUP 
resource "aws_security_group" "instance" {
  name        = "sg_instance"
  description = "Security Group para uma instancia AWS."
  vpc_id      = aws_vpc.vpc_instance.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "SG_INSTANCE_DEV"
  }

}

resource "aws_security_group" "elb" {
  name   = "terraform-elb"
  vpc_id = aws_vpc.vpc_instance.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# LAUCH CONFIGURANTION INSTANCE
resource "aws_launch_configuration" "config_instance" {
  image_id        = "ami-09523541dfaa61c85"
  instance_type   = "t1.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
      #!/bin/bash
      echo "Hello World" > index.html
      nohup busybox httpd -f -p ${var.server_port} &
      EOF

  lifecycle {
    create_before_destroy = true
  }

}

#AUTOSCALING GROUP 
resource "aws_autoscaling_group" "asg_instance" {

  launch_configuration = aws_launch_configuration.config_instance.id
  availability_zones   = data.aws_availability_zones.all.names

  load_balancers    = ["${aws_elb.elb_instance.name}"]
  health_check_type = "ELB"

  min_size = 3
  max_size = 6

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}

#ELB 

resource "aws_elb" "elb_instance" {
  name               = "asg-instance"
  security_groups    = ["${aws_security_group.elb.id}"]
  subnets            = [aws_subnet.vpc_subnet_instance.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}


## INSTANCE 

resource "aws_instance" "instance_micro" {
  ami                    = "ami-09523541dfaa61c85"
  instance_type          = "t1.micro"
  subnet_id              = aws_subnet.vpc_subnet_instance.id
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]


  user_data = <<-EOF
      #!/bin/bash
      echo "Hello World" > index.html
      nohup busybox httpd -f -p ${var.server_port} &
      EOF

  tags = {
    Name = "INSTANCE_DEV_TERRAFORM"
  }



}

## OUTPUTS 

output "public_ip" {
  value = aws_elb.elb_instance.dns_name

}