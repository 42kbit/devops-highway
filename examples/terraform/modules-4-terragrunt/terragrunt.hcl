
locals {
  tg_bucket_name = get_env("TG_BUCKET_NAME", "terragrunt-tfstate-bucket")
}

remote_state {
  backend = "s3"
  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # this will be dry, but name is not generated, which sucks.
    bucket  = local.tg_bucket_name
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
    # can also add dynamodb lock, but its a lab so we dont really care.
  }
  disable_init = false
}

inputs = {
  backend_bucket_name = local.tg_bucket_name
  region = "eu-north-1"
}

generate "region_file" {
  path = "_config.tf"
  if_exists = "overwrite_terragrunt"
  
  contents = <<-EOF
    provider "aws" {
      region = var.region
    }
    
    variable "region" {}
  EOF
}