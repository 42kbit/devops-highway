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
  
  instance_name = "${terraform.workspace}-${var.instance_name}"
  key_name = "${terraform.workspace}-${var.key_name}"
  sec_group_name = "${terraform.workspace}-${var.sec_group_name}"
}

resource "aws_instance" "secured_ec2" {
  ami = var.ami
  instance_type = var.instance_type 
  count = var.instance_count
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_https.id]
  tags = {
    Name = local.instance_name
  }
}
 
output "ec2_public_ip" {
  value = [for i in aws_instance.secured_ec2: "${i.public_ip}"]
  sensitive = true
}

resource "aws_key_pair" "ssh_key" {
  key_name = local.key_name
  public_key = file(var.ssh_public_key_file)
}

resource "aws_security_group" "allow_ssh_https" {
  # else this would result in infinite loop, because
  # terraform tries to destroy attached security group,
  # which is forbidden.
  # see https://github.com/hashicorp/terraform-provider-aws/issues/265
  lifecycle {
    create_before_destroy = true
  }
  name = local.sec_group_name  

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