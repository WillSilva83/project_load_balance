variable "aws_region" {

  default = "sa-east-1"

}


## VARIABLES 
variable "server_port" {
  description = "A porta parao servidor que sera usada para request HTTP."
  default     = 8080
}