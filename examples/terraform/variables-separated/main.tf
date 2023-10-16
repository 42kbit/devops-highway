terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "hello_variables" {
  ami = var.ami
  instance_type = var.instance_type 
  tags = var.funny_tag
  count = var.instance_count
}

resource "aws_iam_user" "iam_users" {
  count = length(var.user_names)
  name = var.user_names[count.index]
  
  tags = {
    Number = "User${count.index + 1}"
  }
}

# since .tfvars are in .gitignore, we cannot add them to commit, so i'll write them here

# terraform.tfvars <- this one is run by default, you can always change
# variable file via -var-file=another.tfvars

# example of variable file:
# 
# instance_count = 3