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
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source = "./modules/vpc"

  name         = var.name
  cluster_name = var.cluster_name
}

module "db" {
  source = "./modules/database"

  name = var.name

  db_name  = "development"
  username = "archie"
  port     = 3306

  vpc_id                    = module.vpc.vpc_id
  vpc_private_subnets       = module.vpc.private_subnets
  vpc_database_subnet_group = module.vpc.database_subnet_group
  vpc_cidr_block            = module.vpc.vpc_cidr_block
}

module "container_registry" {
  source = "./modules/container_registry"

  name = var.name
}

module "eks" {
  source = "./modules/kubernetes"

  cluster_name = var.cluster_name

  acm_certificate_arn = module.dns.acm_certificate_arn

  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.private_subnets

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      additional_userdata  = "echo foo bar"
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

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "17.24.0"

#   cluster_name                    = var.cluster_name
#   cluster_version                 = "1.21"
#   subnets                         = module.vpc.private_subnets
#   cluster_create_timeout          = "1h"
#   cluster_endpoint_private_access = true

#   vpc_id = module.vpc.vpc_id

#   worker_groups = [
#     {
#       name                 = "worker-group-1"
#       instance_type        = "t2.small"
#       additional_userdata  = "echo foo bar"
#       asg_desired_capacity = 1
#     },
#   ]

#   map_users = [
#     {
#       userarn  = module.iam.github_actions_user_arn
#       username = module.iam.github_actions_user_name
#       groups   = ["system:masters"]
#     },
#   ]
# }

module "iam" {
  source = "./modules/iam"

  name = var.name

  ecr_arn         = module.container_registry.arn
  eks_cluster_arn = module.eks.cluster_arn
}

module "dns" {
  source = "./modules/dns"

  domain = var.domain
  records = [{
    name = "auth"
    type = "CNAME"
    ttl  = 60
    records = [
      "dev-archiefinance-cd-tnrhbiq9lkjsiocf.edge.tenants.us.auth0.com"
    ]
  }]
}

module "marketing_website" {
  source = "./modules/static_website"

  name                = "marketing_website"
  description         = "Marketing website"
  domain_name         = var.domain
  acm_certificate_arn = module.dns.acm_certificate_arn

  depends_on = [module.dns]
}

module "mfa_website" {
  source = "./modules/static_website"

  name                = "mfa_website"
  description         = "Mfa website"
  domain_name         = "mfa.${var.domain}"
  acm_certificate_arn = module.dns.acm_certificate_arn

  depends_on = [module.dns]
}

module "dashboard_website" {
  source = "./modules/static_website"

  name                = "dashboard_website"
  description         = "Dashboard website"
  domain_name         = "dashboard.${var.domain}"
  acm_certificate_arn = module.dns.acm_certificate_arn

  depends_on = [module.dns]
}

