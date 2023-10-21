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

resource "aws_instance" "example-name" {
    ami = "ami-0ea7dc624e77a15d5"
    instance_type = "t3.micro"
}

# this will be "provisioned" when ec2 is created and
# ONLY ONCE, not upon every change (because id hasnt changd)
# see "triggers" block
resource "null_resource" "configure_ec2" {
  triggers = {
    # here you can put any shit that will generate dependency
    # init-time or run-time i guess makes a difference
    id = aws_instance.example-name.id
  }
  
  provisioner "local-exec" {
    command = "echo Initializing server..."
  }
}

# this will trigger every time because timestamp is very volatile
resource "null_resource" "i_will_run_every_time" {
  triggers = {
    something = timestamp()
  }
  
  provisioner "local-exec" {
    command = "echo Im triggering" 
  }
}