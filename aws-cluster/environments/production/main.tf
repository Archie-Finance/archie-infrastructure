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

  cloud {
    organization = "archie"

    workspaces {
      name = "archie-production"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "production"
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

module "archie_backend_api_container_registry" {
  source = "../../modules/container_registry"

  name = "archie-production"
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
      instance_type        = "t2.large"
      additional_userdata  = "worker"
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

  eks_cluster_arn = module.eks.cluster_arn
}

module "marketing_website" {
  source = "../../modules/static_website"

  name                = "production_marketing_website"
  description         = "Marketing website"
  domain_name         = "www.${var.domain}"
  alternate_domains   = [var.domain]
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  # ignore_cloudfront_aliases = true

  lambda_function_association = {
    origin-request = {
      lambda_arn   = "arn:aws:lambda:us-east-1:248649311686:function:gatsby-routing:1"
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
      name = "api"
      type = "CNAME"
      ttl  = 60
      records = [
        "k8s-test-566a9892c2-2109929627.us-east-1.elb.amazonaws.com"
      ]
    },
    # {
    #   name = "auth"
    #   type = "CNAME"
    #   ttl  = 60
    #   records = [
    #     "dev-archiefinance-cd-tnrhbiq9lkjsiocf.edge.tenants.us.auth0.com"
    #   ]
    # },
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
    # {
    #   name = "dashboard"
    #   type = "A"
    #   alias = {
    #     name    = module.dashboard_website.cloudfront_distribution_domain_name
    #     zone_id = module.dashboard_website.cloudfront_distribution_hosted_zone_id
    #   }
    # },
  ]
}

# module "db" {
#   source = "../../modules/database-mysql"

#   name = var.name

#   db_name  = "development"
#   username = "archie"
#   port     = 3306

#   vpc_id                    = module.vpc.vpc_id
#   vpc_private_subnets       = module.vpc.private_subnets
#   vpc_database_subnet_group = module.vpc.database_subnet_group
#   vpc_cidr_block            = module.vpc.vpc_cidr_block

#   instance_class = "db.t4g.small"
# }

# module "postgres-db" {
#   source = "../../modules/database-postgres"

#   name = var.name

#   db_name  = "development"
#   username = "archie"

#   vpc_id                    = module.vpc.vpc_id
#   vpc_private_subnets       = module.vpc.private_subnets
#   vpc_database_subnet_group = module.vpc.database_subnet_group
#   vpc_cidr_block            = module.vpc.vpc_cidr_block

#   instance_class = "db.t4g.small"
# }

module "postgres-db" {
  source = "../../modules/database-postgres"

  name = var.name

  db_name  = "production"
  username = "archie"

  vpc_id                    = module.vpc.vpc_id
  vpc_private_subnets       = module.vpc.private_subnets
  vpc_database_subnet_group = module.vpc.database_subnet_group
  vpc_cidr_block            = module.vpc.vpc_cidr_block

  instance_class = "db.t4g.medium"
}

