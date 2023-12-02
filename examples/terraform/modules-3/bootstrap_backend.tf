
locals {
  state_bucket_name = "dh-tfstate-bucket"
}

resource "aws_s3_bucket" "backend_bucket" {
  # name is hardcoded unfortunately
  bucket = local.state_bucket_name

  force_destroy = true
  lifecycle {
    create_before_destroy = true
  }
}

output "state_bucket_name" {
  value = local.state_bucket_name
}
