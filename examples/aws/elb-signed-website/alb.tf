
# defines application load balancer that has following security groups
# and operate in following subnets (where asg creates instances)
resource "aws_alb" "main" {
  name               = "alb-main"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https.id]
  subnets            = [for subnet in data.aws_subnet.all_defaults : subnet.id]
}

# defines a group of resources that are capable of recieving connection to
# port 80 with HTTP protocol.
# They also have a delay of 10 seconds before deregistering instance.
# asg will append its list of instances, watch field target_group_arns 
resource "aws_alb_target_group" "http80" {
  name                 = "${aws_alb.main.name}-tg-http80"
  vpc_id               = aws_default_vpc.default.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10
}

# if packet came from port 80 and uses HTTP protocol, forward it to this group.
resource "aws_alb_listener" "http80" {
  load_balancer_arn = aws_alb.main.arn
  port              = 80
  protocol          = "HTTP"

  # throw 301 and redirect to https

  #default_action {
  #  type = "redirect"

  #  redirect {
  #    port        = "443"
  #    protocol    = "HTTPS"
  #    status_code = "HTTP_301"
  #  }
  #}

  # allow http

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.http80.arn
  }
}

resource "aws_alb_target_group" "https443" {
  name                 = "${aws_alb.main.name}-tg-https443"
  vpc_id               = aws_default_vpc.default.id
  port                 = 443
  protocol             = "HTTPS"
  deregistration_delay = 10
}

resource "aws_alb_listener" "https443" {
  load_balancer_arn = aws_alb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.https443.arn
  }
}

output "info_about_changing_mapping_cname_by_hand" {
  value = <<-EOF
  Since in this lab terraform does not own your route53 domain zone,
  you shall change alias maping by hand. Proceed with following entry:
    A (Alias) [${var.certificate_domain} -> ${aws_alb.main.dns_name}]
  EOF
}
