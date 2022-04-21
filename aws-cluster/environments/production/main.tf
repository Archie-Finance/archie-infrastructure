terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }

  backend "s3" {
    bucket         = "archie-finance-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "archie-finance-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
}

module "certificate_manager" {
  source = "../../modules/certificate_manager"

  zone_id = var.zone_id
  domain  = var.domain
}

module "marketing_website" {
  source = "../../modules/static_website"

  name                = "marketing_website"
  description         = "Marketing website"
  domain_name         = var.domain
  alternate_domains   = ["www.${var.domain}"]
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  lambda_function_association = {
    origin-request = {
      lambda_arn   = "arn:aws:lambda:us-east-1:108827241267:function:gatsby-routing:4"
      include_body = false
    }
  }

  depends_on = [module.certificate_manager]
}

module "route53" {
  source = "../../modules/route53"

  zone_id = var.zone_id

  records = [
    {
      name = ""
      type = "A"
      alias = {
        name    = module.marketing_website.cloudfront_distribution_domain_name
        zone_id = module.marketing_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "www"
      type = "A"
      alias = {
        name    = module.marketing_website.cloudfront_distribution_domain_name
        zone_id = module.marketing_website.cloudfront_distribution_hosted_zone_id
      }
    }
  ]
}
