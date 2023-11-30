
resource "aws_security_group" "mysql_ssh" {
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = ["22", "3306"]
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

resource "random_password" "mysql_root_password" {
  length           = 32
  special          = true
  override_special = "_%@" # what specials to allow
}

output "mysql_root_password" {
  value     = random_password.mysql_root_password.result
  sensitive = true
}

variable "db_instance_type" {
  type    = string
  default = "db.t3.micro"
}

resource "aws_db_instance" "main" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = var.db_instance_type
  engine_version       = "5.7"
  parameter_group_name = "default.mysql5.7"

  username = "root"
  password = random_password.mysql_root_password.result

  vpc_security_group_ids = [aws_security_group.mysql_ssh.id]
  skip_final_snapshot    = true

  tags = {
    Name = "RDS Sandbox"
  }

  publicly_accessible = true
}
