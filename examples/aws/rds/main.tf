
terraform {
  required_providers {
    aws = {
    }
  }
}

variable "region" {}

provider "aws" {
  region = var.region
}
