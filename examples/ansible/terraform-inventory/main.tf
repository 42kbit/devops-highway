
variable "ansible_pub_key_path" {}
variable "ansible_pri_key_path" {}
variable "terraform_inventory_path" {
  default     = "/usr/bin/terraform-inventory"
  description = "Terraform dynamic inventory for Ansible"
}
variable "instances_info" {
  type = list(object({
    user = string
    ami  = string
  }))
}
variable "region" {}

# Instances info example:
# 
# instances_info = [ {
#   user = "ec2-user"
#   ami = "ami-0ea7dc624e77a15d5", # Amazon Linux
# }]

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "hello_world" {
  count                  = length(var.instances_info)
  ami                    = var.instances_info[count.index].ami
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.hello_world.key_name
  vpc_security_group_ids = [aws_security_group.hello_world.id]
  tags = {
    User = var.instances_info[count.index].user
  }

  depends_on = [aws_security_group.hello_world, aws_key_pair.hello_world]
}

resource "aws_key_pair" "hello_world" {
  key_name   = "ansible_pub_key"
  public_key = file(var.ansible_pub_key_path)
}

resource "aws_security_group" "hello_world" {
  name        = "hello_world_allow_ssh"
  description = "Allows ssh for ansible"
  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description      = "ssh from vpc"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http for vpc"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "null_resource" "check_ssh_connectivity" {
  count = length(var.instances_info)
  triggers = {
    run_everytime = timestamp()
  }
  # this shit will ensure that connection can be established
  # before starting ansible. More:
  # https://stackoverflow.com/questions/62403030/terraform-wait-till-the-instance-is-reachable

  provisioner "remote-exec" {
    connection {
      host        = aws_instance.hello_world[count.index].public_ip
      user        = var.instances_info[count.index].user
      private_key = file(var.ansible_pri_key_path)
    }
    inline = ["echo Connection can be established, starting ansible..."]
  }
}

resource "null_resource" "configure_ansible" {
  triggers = {
    run_everytime = timestamp()
  }
  depends_on = [
    null_resource.check_ssh_connectivity,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_SSH_KEY_FILE=${var.ansible_pri_key_path} \
      TF_STATE=./ \
      ansible-playbook \
      -i ${var.terraform_inventory_path} \
      main.yml
    EOT

  }
}
