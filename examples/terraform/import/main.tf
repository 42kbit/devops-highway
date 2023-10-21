terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# try creating by hand aws ubuntu instance, then associate
# it with aws_instance.example_name resource in terraform
# with "terraform import aws_instance.example_name *instance_id*"
# then try to plan and see it changes image from ubuntu to 
# amazon linux, as we setup here.
resource "aws_instance" "example_name" {
  # ami = "ami-0fe8bec493a81c7da" # ubuntu
  ami = "ami-0d2ca4d7e5645e504" # amazon linux
  instance_type = "t3.micro"
  
  tags = {
    Name = "my-test-instance"
  }
}