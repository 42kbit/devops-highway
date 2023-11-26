
resource "aws_security_group" "https" {
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = ["80", "443"]
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

variable "template_instance_type" {}

resource "aws_launch_template" "main" {
  name                   = "main_launch_configuration"
  image_id               = data.aws_ami.latest_amazon_linux_2.id
  instance_type          = var.template_instance_type
  vpc_security_group_ids = [aws_security_group.https.id]

  user_data = filebase64("./init_webserver.sh")
}
