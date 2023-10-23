# comments start with # (hash symbol) symbol

# syntax seems werid at first, kinda like nginx .conf

# this block describes terraform parameters
# which providers to install
# which remotes to use
terraform {
  required_providers {
    # download aws support from hashicorp/aws
    # from official registry at registry.terraform.io
    # see https://registry.terraform.io/providers/hashicorp/aws/latest

    # providers are kinda like plug-ins, an abstraction that
    # allows terraform "core" to communicate with cloud provider via some api
    # in case of aws, "hashicorp/aws" interracts with aws api,
    # which should be preconfigured, with IAM public and private keys
    # via "aws configure"
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# aws provider requires us to specify region, i'll pick closest
provider "aws" {
  region = "eu-north-1"
}

# now lets define resources that should be made, shall we?

# "aws_instance" string, is a tag, that specifies what should we create, in
#   this case - ec2 instance.
# "example-name" string, is a tag, that specifies name (doesn't matter for now)
resource "aws_instance" "example-name" {
  ami = "ami-0ea7dc624e77a15d5" # image of virtual machine, in this case
  # Amazon Linux image (x86)
  instance_type = "t3.micro" # this one, cuz it is free. (Oct. 2023)
}

# Ok done, 20 lines or so without comments, lets run this baddie:
#   terraform init    (Download aws provider implementation)
#   terraform plan    (Shows difference between desired and current state)
#   terraform apply   (Applies changes from "plan")
#   terraform destroy (Terminates every present resource)