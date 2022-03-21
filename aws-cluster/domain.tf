module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.6.0"

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
    "mfa.${var.domain}",
    "dashboard.${var.domain}"
  ]

  wait_for_validation = true

  tags = {
    Name = var.domain
  }
}

module "marketing_website" {
  source = "./modules/static_website"

  name = "marketing_website"
  description = "Marketing website"
  domain_name = var.domain
  acm_certificate_arn = module.acm.acm_certificate_arn

  depends_on = [module.acm]
}

module "mfa_website" {
  source = "./modules/static_website"

  name = "mfa_website"
  description = "Mfa website"
  domain_name = "mfa.${var.domain}"
  acm_certificate_arn = module.acm.acm_certificate_arn

  depends_on = [module.acm]
}

module "dashboard_website" {
  source = "./modules/static_website"

  name = "dashboard_website"
  description = "Dashboard website"
  domain_name = "dashboard.${var.domain}"
  acm_certificate_arn = module.acm.acm_certificate_arn

  depends_on = [module.acm]
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
      name = "auth"
      type = "CNAME"
      ttl = 60
      records = [
        "dev-archiefinance-cd-tnrhbiq9lkjsiocf.edge.tenants.us.auth0.com"
      ]
    },
    {
      name = "mfa"
      type = "A"
      alias = {
        name    = module.mfa_website.cloudfront_distribution_domain_name
        zone_id = module.mfa_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "mfa"
      type = "AAAA"
      alias = {
        name    = module.mfa_website.cloudfront_distribution_domain_name
        zone_id = module.mfa_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "dashboard"
      type = "A"
      alias = {
        name    = module.dashboard_website.cloudfront_distribution_domain_name
        zone_id = module.dashboard_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "dashboard"
      type = "AAAA"
      alias = {
        name    = module.dashboard_website.cloudfront_distribution_domain_name
        zone_id = module.dashboard_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = ""
      type = "A"
      alias = {
        name    = module.marketing_website.cloudfront_distribution_domain_name
        zone_id = module.marketing_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = ""
      type = "AAAA"
      alias = {
        name    = module.marketing_website.cloudfront_distribution_domain_name
        zone_id = module.marketing_website.cloudfront_distribution_hosted_zone_id
      }
    }
  ]

  depends_on = [module.zones, kubernetes_service.example]
}
