
variable "vpc_id" {}

# gotta specify type if importing from terragrunt, since it will send
# list as a string.

variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}

resource "aws_security_group" "ssh" {
  # gather from networks branch
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = ["22", "8080", "8443"]
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
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
  subnet_id       = var.public_subnet_ids[0]
  instance_type   = var.ec2_test_instances_info.instance_type
  ami             = data.aws_ami.ubuntu.id
  security_groups = [aws_security_group.ssh.id]
  key_name        = aws_key_pair.key.key_name
  user_data       = file("./jenkins_stable_install.sh")
  tags = {
    Name = "Jenkins server"
  }
}
