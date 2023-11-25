
variable "domain_zone_id" {
  type        = string
  description = "Registered in AWS domain zone, that should be imported"
}

variable "certificate_domain" {
  type        = string
  description = "Domain name (or wildcard) of existing, valid certificate"
}

data "aws_route53_zone" "main" {
  zone_id = var.domain_zone_id
}

data "aws_acm_certificate" "main" {
  domain      = var.certificate_domain
  most_recent = true
}
