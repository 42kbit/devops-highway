
resource "aws_elb" "main" {
  name               = "elb-main"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = [aws_security_group.https.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80 # map 80 -> 80 (lb_port -> instance_port)
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443 # map 443 -> 80 (ssl termination)
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = data.aws_acm_certificate.main.id
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

output "info_about_changing_mapping_cname_by_hand" {
  value = <<-EOF
  Since in this lab terraform does not own your route53 domain zone,
  you shall change alias maping by hand. Proceed with following entry:
    A (Alias) [${var.certificate_domain} -> ${aws_elb.main.dns_name}]
  EOF
}
