
terraform {
  required_providers {
    aws = {}
  }
}

variable "default_region" {}

provider "aws" {
  region = var.default_region
}

# this is basically reusable chunk of code (aka function)
module "created_networks" {
  source = "./modules/aws_network"

  # specify variables like an arguments to a function.
  # read output like an output from a function (see servers.tf)
  vpc = {
    cidr_block = "10.0.0.0/16"
  }
  subnets = [
    {
      cidr_block = "10.0.1.0/24"
      is_public  = true
    },
    {
      cidr_block = "10.0.2.0/24"
      is_public  = true
    },
    {
      cidr_block = "10.0.3.0/24"
      is_public  = false
    },
    {
      cidr_block = "10.0.4.0/24"
      is_public  = false
    }
  ]
}
