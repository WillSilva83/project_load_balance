provider "aws" {
  region = var.region_default
}

resource "aws_dynamodb_table" "terraform-locks-dynamodb=dev" {
  name = "terraform-locks-dev"
  billing_mode = "PROVISIONED"

  read_capacity = 1 
  write_capacity = 1


    hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }


  tags = {
    Name = "terraform-dynamodb-locks"
    Env = Dev
  }
}