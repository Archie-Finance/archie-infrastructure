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
    "dashboard.${var.domain}",
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

  records = var.records
}
