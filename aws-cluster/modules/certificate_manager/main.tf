module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.domain
  zone_id = var.zone_id

  subject_alternative_names = [
    "*.${var.domain}",
  ]

  # wait_for_validation = false

  tags = {
    Name = var.domain
  }
}
