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
    key            = "environments/development/terraform.tfstate"
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


module "vpc" {
  source = "../../modules/vpc"

  name         = var.name
  cluster_name = var.cluster_name
}

module "container_registry" {
  source = "../../modules/container_registry"

  name = var.name
}

module "eks" {
  source = "../../modules/kubernetes"

  cluster_name = var.cluster_name

  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.private_subnets

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      additional_userdata  = "development worker"
      asg_desired_capacity = 1
    },
  ]

  map_users = [
    {
      userarn  = module.iam.github_actions_user_arn
      username = module.iam.github_actions_user_name
      groups   = ["system:masters"]
    },
  ]
}

module "iam" {
  source = "../../modules/iam"

  name = var.name

  ecr_arn         = module.container_registry.arn
  eks_cluster_arn = module.eks.cluster_arn
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

module "mfa_website" {
  source = "../../modules/static_website"

  name                = "mfa_website"
  description         = "Mfa website"
  domain_name         = "mfa.${var.domain}"
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  depends_on = [module.certificate_manager]
}

module "dashboard_website" {
  source = "../../modules/static_website"

  name                = "dashboard_website"
  description         = "Dashboard website"
  domain_name         = "dashboard.${var.domain}"
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  depends_on = [module.certificate_manager]
}

module "route53" {
  source = "../../modules/route53"

  zone_id = var.zone_id

  records = [
    {
      name = "api"
      type = "CNAME"
      ttl  = 60
      records = [
        "a7840d34c44ce40a6a2f405fa0a4718f-494685174.us-east-1.elb.amazonaws.com"
      ]
    },
    {
      name = "auth"
      type = "CNAME"
      ttl  = 60
      records = [
        "dev-archiefinance-cd-tnrhbiq9lkjsiocf.edge.tenants.us.auth0.com"
      ]
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
      name = "www"
      type = "A"
      alias = {
        name    = module.marketing_website.cloudfront_distribution_domain_name
        zone_id = module.marketing_website.cloudfront_distribution_hosted_zone_id
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
      name = "mfa"
      type = "A"
      alias = {
        name    = module.mfa_website.cloudfront_distribution_domain_name
        zone_id = module.mfa_website.cloudfront_distribution_hosted_zone_id
      }
    }
  ]
}

module "db" {
  source = "../../modules/database"

  name = var.name

  db_name  = "development"
  username = "archie"
  port     = 3306

  vpc_id                    = module.vpc.vpc_id
  vpc_private_subnets       = module.vpc.private_subnets
  vpc_database_subnet_group = module.vpc.database_subnet_group
  vpc_cidr_block            = module.vpc.vpc_cidr_block
}
