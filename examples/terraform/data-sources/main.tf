terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
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

resource "aws_instance" "secured_ec2" {
  ami = var.ami
  instance_type = var.instance_type 
  count = var.instance_count
  key_name = "ssh_key"
  vpc_security_group_ids = [aws_security_group.allow_ssh_https.id]
  
  tags = {
    Name = "EC2 Instance"
  }
}

data "aws_instances" "ec2_named_instances" {
  filter {
    name = "tag:Name"
    values = ["EC2 Instance"]
  }
  
  # should wait for its creation
  depends_on = [ aws_instance.secured_ec2 ]
}

# data sources can do all sorts of stuff, this one zips file
data "archive_file" "zip_file_txt" {
  type = "zip"
  # can only zip directories otherwise:
  # error: could not archive directory that is a file: ./file.txt
  source_dir = "${path.module}/file-dir"
  output_path = "${path.module}/file-dir.zip"
}

data "aws_instances" "ec2_with_ssh_keys" {
  filter {
    # NOTE: WE ARE USING FUCKING DASH(-) AND NOT UNDERSCORE(_)
    name = "key-name"
    values = ["ssh_key"]
  }

  # should wait for its creation
  depends_on = [ aws_instance.secured_ec2 ]
}
 
 
output "ec2_public_ip" {
  value = data.aws_instances.ec2_named_instances.public_ips
  sensitive = true
}

output "ec2_with_keys_private_ip" {
  value = data.aws_instances.ec2_with_ssh_keys.private_ips
  sensitive = true
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