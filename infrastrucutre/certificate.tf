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

data "kubernetes_ingress_v1" "app_ingress" {
  depends_on = [helm_release.vega-course-app]

  metadata {
    name      = "${helm_release.vega-course-app.name}-ingress"
    namespace = helm_release.vega-course-app.namespace
  }
}

locals {
  alb_name_parts = split("-", split(".", data.kubernetes_ingress_v1.app_ingress.status.0.load_balancer.0.ingress.0.hostname).0)
}


data "aws_lb" "app_lb" {
  depends_on = [helm_release.vega-course-app]
  name       = join("-", slice(local.alb_name_parts, 0, length(local.alb_name_parts) - 1))
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

