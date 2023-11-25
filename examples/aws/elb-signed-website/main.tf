
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {}

# select all avail zones from default vpc
data "aws_availability_zones" "all" {}

# select all default subnets from all avail zones
data "aws_subnet" "all_defaults" {
  count             = length(data.aws_availability_zones.all.names)
  availability_zone = data.aws_availability_zones.all.names[count.index]
  default_for_az    = true
}

provider "aws" {
  region = var.region
}
