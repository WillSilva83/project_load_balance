provider "aws" {
  region = "sa-east-1"
}

resource "aws_vpc" "default_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "default_vpc"
    Env  = "DEV"

  }
}

