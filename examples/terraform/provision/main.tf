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
}

resource "aws_instance" "secured_ec2" {
  ami = var.ami
  instance_type = var.instance_type 
  count = var.instance_count
  key_name = "ssh_key"
  vpc_security_group_ids = [aws_security_group.allow_in_tcp22.id]
  
  connection {
    type = "ssh"
    host = self.public_ip
    user = local.aws_login_user
    private_key = file (var.ssh_private_key_file)
    timeout = "4m"
  }
  
  provisioner "file" {
    source = "./file.txt"
    destination = "/home/${local.aws_login_user}/file.txt"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = file(var.ssh_public_key_file)
}

resource "aws_security_group" "allow_in_tcp22" {
  name = "allow_tcp22"
  
  egress = toset([{
    description = ""
    prefix_list_ids = []
    security_groups = []
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = []
    self = false
  }])

  ingress = toset([{
    cidr_blocks = [ "0.0.0.0/0" ]
    description = ""
    from_port = 22
    to_port = 22
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
  }])
}