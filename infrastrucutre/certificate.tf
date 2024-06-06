data "aws_route53_zone" "selected" {
  name         = var.route_53_zone_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.selected.zone_id

  validation_method = "DNS"

  wait_for_validation = true
}

data "aws_lb" "app_lb" {
  name = var.app_load_balancer
}

resource "aws_route53_record" "app_dns_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.aws_lb.app_lb.dns_name
    zone_id                = data.aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

