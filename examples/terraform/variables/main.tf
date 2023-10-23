terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "ami" {
  description = "AWS AMI"
  type        = string
  default     = "ami-0ea7dc624e77a15d5"
}

variable "instance_type" {
  description = "AWS Instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "user_names" {
  description = "IAM Users"
  type        = list(string)
  default     = ["user1", "user2", "user3"]
}

variable "funny_tag" {
  description = "Defines funny tag"
  type        = map(string) # map is a key value, in this case: key maps to string
  default = {
    "funnys" = "YES"
  }
}

provider "aws" {
  region = var.region
}

# Note: Count is a meta-variable!
# By default, a resource block configures one real infrastructure object.
# (Similarly, a module block includes a child module's
# contents into the configuration one time.)
# However, sometimes you want to manage several similar objects
# (like a fixed pool of compute instances) without writing
# a separate block for each one.
# Terraform has two ways to do this: count and for_each.

# If a resource or module block includes a count argument whose value is a
# whole number, Terraform will create that many instances.

# https://developer.hashicorp.com/terraform/language/meta-arguments/count

resource "aws_instance" "hello_variables" {
  ami           = var.ami # Amazon Linux image (x86)
  instance_type = var.instance_type
  # tag is a map of strings
  tags  = var.funny_tag
  count = var.instance_count # run this resource code "var.instance_count" times.
}

# count.index — The distinct index number (starting with 0)
# corresponding to this instance.

resource "aws_iam_user" "iam_users" {
  count = length(var.user_names)
  name  = var.user_names[count.index]

  tags = {
    Number = "User${count.index + 1}"
  }
}