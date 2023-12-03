
remote_state {
  backend = "s3"
  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # this will be dry, but name is not generated, which sucks.
    bucket  = "terragrunt-tfstate-bucket"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
  disable_init = false
}

inputs = {
  backend_bucket_name = "terragrunt-tfstate-bucket"
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