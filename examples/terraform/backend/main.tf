terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  
  # comment it, deploy, uncomment, reinit
  # backend "s3" {
  #   bucket = "my-funny-terraform-state-bucket"
  #   key = "key/terraform.tfstate"
  #   region = "eu-north-1"
  #   dynamodb_table = "tf-state-lock"
  #   encrypt = false
  # }
}

locals {
  state_bucket_name = "my-funny-terraform-state-bucket"
}

provider "aws" {
  region = var.region
}

locals {
  aws_login_user = "ec2-user" # works for every except ubuntu
  ingress_rules = [{
    description = "SSH Connection"
    from_port = 22
    to_port = 22
  }, {
    description = "HTTPS Connection"
    from_port = 443
    to_port = 443
  }, {
    description = "HTTP Connection"
    from_port = 80
    to_port = 80
  }]
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = local.state_bucket_name
  force_destroy = true
  
  tags = {
    Name = local.state_bucket_name
    Environment = terraform.workspace
  }
}

# Create dynamodb table with primary key LockID (string)
resource "aws_dynamodb_table" "state_lock" {
  name = "tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "secured_ec2" {
  ami = var.ami
  instance_type = var.instance_type 
  count = var.instance_count
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_https.id]
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = file(var.ssh_public_key_file)
}

resource "aws_security_group" "allow_ssh_https" {
  name = "allow_ssh_https"
  
  # egress = toset([{
  #   description = ""
  #   prefix_list_ids = []
  #   security_groups = []
  #   from_port = 0
  #   to_port = 0
  #   protocol = "-1"
  #   cidr_blocks = [ "0.0.0.0/0" ]
  #   ipv6_cidr_blocks = []
  #   self = false
  # }])
 
  egress {
    description = ""
    prefix_list_ids = []
    security_groups = []
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = []
    self = false
  }

  # this is by far the greatest what the fuck moment
  # seems like it unrolles for_each loop into multiple blocks
  dynamic "ingress" {
    for_each = local.ingress_rules
    iterator = wtf 
    
    content {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = wtf.value.description
      from_port = wtf.value.from_port
      to_port = wtf.value.to_port
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "tcp"
      security_groups = []
      self = false
    }
  }
}