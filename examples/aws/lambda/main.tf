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

data "aws_iam_policy_document" "lambda_iam_role_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_policy_s3_readonly_document" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "terraform_aws_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_iam_role_document.json
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name   = "terraform_aws_lambda_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_policy_s3_readonly_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_iam_role_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

data "archive_file" "lambda_code_zipped" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/code.zip"
  depends_on  = [null_resource.run_everytime]
}

resource "null_resource" "run_everytime" {
  triggers = {
    run_everytime = timestamp()
  }
}

# Ok so now (14 Nov. 2023) i've encountered the bug that makes
# this resource be uploaded everytime, see
# https://github.com/hashicorp/terraform-provider-aws/issues/29085
# (last_modified changes, forcing terraform to upload),
# there is also potential diff in hashes, which are only known at runtime,
# but as long as code does not change, it will get the same hash from
# zipped archive, and thus wont upload a change.

# so change is forced by bug, not really my problem here (unless im very dumb)

resource "aws_lambda_function" "lambda_function" {
  filename         = "${path.module}/code.zip"
  function_name    = "TerraformLambdaFunction"
  role             = aws_iam_role.lambda_iam_role.arn
  source_code_hash = data.archive_file.lambda_code_zipped.output_base64sha512
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.8"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_iam_role_attachment,
    data.archive_file.lambda_code_zipped
  ]
}

# Now lets define some buckets to work with.

resource "time_static" "now" {}

resource "aws_s3_bucket" "lambda_s3_bucket" {
  # this wont run every time, because time_static is created once,
  # and not every run (unlike timestamp()).
  bucket = "lambda-playgroud-bucket-${time_static.now.unix}"

  force_destroy = true
  lifecycle {
    create_before_destroy = true
  }
}
