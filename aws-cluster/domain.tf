module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "${var.domain}" = {
      comment = "development domain zone"
      tags = {
        env = "development"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.domain
  zone_id     = module.zones.route53_zone_zone_id[var.domain]

  subject_alternative_names = [
    "api.${var.domain}",
  ]

  wait_for_validation = true

  tags = {
    Name = var.domain
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.domain

  records = [
    {
      name = "api"
      type = "CNAME"
      ttl  = 60
      records = [
        kubernetes_service.example.status.0.load_balancer.0.ingress.0.hostname
      ]
    },
    {
      name = ""
      type = "A"
      alias = {
        name    = module.cdn.cloudfront_distribution_domain_name
        zone_id = module.cdn.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = ""
      type = "AAAA"
      alias = {
        name    = module.cdn.cloudfront_distribution_domain_name
        zone_id = module.cdn.cloudfront_distribution_hosted_zone_id
      }
    }
  ]

  depends_on = [module.zones, kubernetes_service.example]
}
