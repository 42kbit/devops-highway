
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
    }
  }
}
