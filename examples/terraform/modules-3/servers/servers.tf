

# BAM copy pasting code! how the fuck do you suppose to fix this
# since terraform block prohibits USE of locals or variable?
terraform {
  backend "s3" {
    bucket = "dh-tfstate-bucket"
    key    = "prod/servers/terraform.tfstate"
    region = "eu-north-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  # ONCE AGAIN HARDCODE UUUUGH
  config = {
    bucket = "dh-tfstate-bucket"
    key    = "prod/network/terraform.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "ssh" {
  # gather from networks branch
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  dynamic "ingress" {
    for_each = ["22"]
    content {
      from_port        = ingress.value
      to_port          = ingress.value # open only one port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "latest_amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }
}

variable "ec2_test_instances_info" {
  type = object({
    instance_type       = string,
    public_key_filepath = string
  })
}

resource "aws_key_pair" "key" {
  public_key = file(var.ec2_test_instances_info.public_key_filepath)
}

resource "aws_instance" "test_instance" {
  subnet_id       = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  instance_type   = var.ec2_test_instances_info.instance_type
  ami             = data.aws_ami.latest_amazon_linux_2.id
  security_groups = [aws_security_group.ssh.id]
  key_name        = aws_key_pair.key.key_name
  tags = {
    Name = "Test Instance"
  }
}


resource "aws_instance" "test_instance2" {
  subnet_id       = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
  instance_type   = var.ec2_test_instances_info.instance_type
  ami             = data.aws_ami.latest_amazon_linux_2.id
  security_groups = [aws_security_group.ssh.id]
  key_name        = aws_key_pair.key.key_name
  tags = {
    Name = "Test Instance (PRIVATE)"
  }
}

