terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }

  cloud {
    organization = "archie"

    workspaces {
      name = "archie-development"
    }
  }
}

variable "access_key" {}
variable "secret_key" {}
variable "region" {}

provider "aws" {
  region     = var.region
  secret_key = var.secret_key
  access_key = var.access_key
}

data "aws_availability_zones" "available" {
}

module "certificate_manager" {
  source = "../../shared/terraform/modules/certificate_manager"

  zone_id = var.zone_id
  domain  = var.domain
}


module "vpc" {
  source = "../../shared/terraform/modules/vpc"

  name         = var.name
  cluster_name = var.cluster_name
}

module "archie_backend_api_container_registry" {
  source = "../../shared/terraform/modules/container_registry"

  name = "archie-development"
}

module "archie_testing_portal_container_registry" {
  source = "../../shared/terraform/modules/container_registry"

  name = "archie-testing-portal"
}

module "eks" {
  source = "../../shared/terraform/modules/kubernetes"

  cluster_name = var.cluster_name

  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.private_subnets

  worker_groups = [
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      additional_userdata  = "development worker"
      asg_desired_capacity = 1
    },
    {
      name                 = "worker-group-3"
      instance_type        = "t2.large"
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
    {
      userarn  = module.iam_kubernetes_access.developer_access_user_arn
      username = module.iam_kubernetes_access.developer_access_user_name
      groups   = ["system:masters"]
    },
  ]
}

module "iam" {
  source = "../../shared/terraform/modules/iam"

  name = var.name

  eks_cluster_arn = module.eks.cluster_arn
}

module "iam_kubernetes_access" {
  source = "../../shared/terraform/modules/iam_kubernetes_access"

  name = var.name

  eks_cluster_arn = module.eks.cluster_arn
}

module "marketing_website" {
  source = "../../shared/terraform/modules/static_website"

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

module "dashboard_website" {
  source = "../../shared/terraform/modules/static_website"

  name                = "dashboard_website"
  description         = "Dashboard website"
  domain_name         = "dashboard.${var.domain}"
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  depends_on = [module.certificate_manager]
}

module "testing_portal" {
  source = "../../shared/terraform/modules/static_website"

  name                = "testing_portal"
  description         = "Testing portal website"
  domain_name         = "portal.${var.domain}"
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  depends_on = [module.certificate_manager]
}

module "design_system_website" {
  source = "../../shared/terraform/modules/static_website"

  name                = "design_system_website"
  description         = "Design system website"
  domain_name         = "design-system.${var.domain}"
  acm_certificate_arn = module.certificate_manager.acm_certificate_arn

  depends_on = [module.certificate_manager]
}

module "route53" {
  source = "../../shared/terraform/modules/route53"

  zone_id = var.zone_id

  records = [
    {
      name = "api"
      type = "CNAME"
      ttl  = 60
      records = [
        "k8s-test-e17eb4024e-594389964.us-east-1.elb.amazonaws.com"
      ]
    },
    {
      name = "ws"
      type = "CNAME"
      ttl  = 60
      records = [
        "k8s-test-e17eb4024e-594389964.us-east-1.elb.amazonaws.com"
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
      name = "portal-api"
      type = "CNAME"
      ttl  = 60
      records = [
        "k8s-testingportalingr-af3ae9614b-529328079.us-east-1.elb.amazonaws.com"
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
      name = "design-system"
      type = "A"
      alias = {
        name    = module.design_system_website.cloudfront_distribution_domain_name
        zone_id = module.design_system_website.cloudfront_distribution_hosted_zone_id
      }
    },
    {
      name = "portal"
      type = "A"
      alias = {
        name    = module.testing_portal.cloudfront_distribution_domain_name
        zone_id = module.testing_portal.cloudfront_distribution_hosted_zone_id
      }
    }
  ]
}

module "postgres-db" {
  source = "../../shared/terraform/modules/database-postgres"

  name = var.name

  db_name  = "development"
  username = "archie"

  vpc_id                    = module.vpc.vpc_id
  vpc_private_subnets       = module.vpc.private_subnets
  vpc_database_subnet_group = module.vpc.database_subnet_group
  vpc_cidr_block            = module.vpc.vpc_cidr_block

  instance_class = "db.t4g.small"
}

module "vault_backup" {
  source = "../../shared/terraform/modules/vault_backup"
}
