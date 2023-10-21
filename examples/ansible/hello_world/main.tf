terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

variable "ansible_pub_key_path" {}
variable "ansible_pri_key_path" {}

resource "aws_instance" "hello_world" {
  ami = "ami-0ea7dc624e77a15d5"
  instance_type = "t3.micro"
  key_name = aws_key_pair.hello_world.key_name
  vpc_security_group_ids = [aws_security_group.hello_world.id]

  depends_on = [aws_security_group.hello_world, aws_key_pair.hello_world]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory"
  content = templatefile("${path.module}/inventory.tpl", {
    public_ips = [aws_instance.hello_world.public_ip]
  })
}

resource "aws_key_pair" "hello_world" {
  key_name = "ansible_pub_key"
  public_key = file(var.ansible_pub_key_path)
}

resource "aws_security_group" "hello_world" {
  name        = "hello_world_allow_ssh"
  description = "Allows ssh for ansible"

  ingress {
    description      = "ssh from vpc"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "null_resource" "configure_ansible" {
  triggers = {
    # hwi_id = aws_instance.hello_world.id
    run_everytime = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible all --key-file ${var.ansible_pri_key_path} \
      -i ${local_file.ansible_inventory.filename} \
      -m ping --user ec2-user
    EOT
  }
}