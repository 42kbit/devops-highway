
variable "ansible_pub_key_path" {}
variable "ansible_pri_key_path" {}
variable "instances_info" {
  type = list(object({
    user = string
    ami = string
    args = list(string)
  }))
}
variable "region" {}

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

resource "aws_instance" "hello_world" {
  count = length(var.instances_info)
  ami = var.instances_info[count.index].ami
  instance_type = "t3.micro"
  key_name = aws_key_pair.hello_world.key_name
  vpc_security_group_ids = [aws_security_group.hello_world.id]

  depends_on = [aws_security_group.hello_world, aws_key_pair.hello_world]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory"
  content = templatefile("${path.module}/inventory.tpl", {
    # todo add concat here
    cons = [for idx, i in var.instances_info : {
      ip = aws_instance.hello_world[idx].public_ip
      args = i.args
    }]
  })
}

resource "aws_key_pair" "hello_world" {
  key_name = "ansible_pub_key"
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
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http for vpc"
    from_port        = 80
    to_port          = 80
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
  #  count = length(var.instances_info)
  # servers are already in inventory
  triggers = {
    # run everytime
    run_everytime = timestamp()
    inventory_generated = local_file.ansible_inventory.content_sha1
  }

  # this shit will ensure that connection can be established
  # before starting ansible. More:
  # https://stackoverflow.com/questions/62403030/terraform-wait-till-the-instance-is-reachable
  
  # TODO: make those not shit (ctrl-c ctrl-v)
  #       and runned in paralel
  provisioner "remote-exec" {

    connection {
      host = aws_instance.hello_world[0].public_ip
      user = var.instances_info[0].user
      private_key = file(var.ansible_pri_key_path)
    }

    inline = [ "echo Connection can be established, starting ansible..." ]
  }

  provisioner "remote-exec" {

    connection {
      host = aws_instance.hello_world[1].public_ip
      user = var.instances_info[1].user
      private_key = file(var.ansible_pri_key_path)
    }

    inline = [ "echo Connection can be established, starting ansible..." ]
  }

  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible all --key-file ${var.ansible_pri_key_path} \
      -i ${local_file.ansible_inventory.filename} \
      -m ping;

      ansible-playbook --key-file ${var.ansible_pri_key_path} \
      -i ${local_file.ansible_inventory.filename} \
      apache_init.yml
    EOT
  }
}