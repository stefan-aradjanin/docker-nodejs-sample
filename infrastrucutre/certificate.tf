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
