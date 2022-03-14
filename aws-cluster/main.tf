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

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.21"
  subnets                         = module.vpc.private_subnets
  cluster_create_timeout          = "1h"
  cluster_endpoint_private_access = true

  vpc_id = module.vpc.vpc_id

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
      userarn  = module.iam_user_github_actions.iam_user_arn
      username = module.iam_user_github_actions.iam_user_name
      groups   = ["system:masters"]
    },
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-example"

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = module.acm.acm_certificate_arn
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"        = "https"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
    }
  }

  spec {
    selector = {
      test = "archie-backend"
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
