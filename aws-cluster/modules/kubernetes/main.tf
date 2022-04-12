module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.21"
  subnets                         = var.vpc_private_subnets
  cluster_create_timeout          = "1h"
  cluster_endpoint_private_access = true

  vpc_id = var.vpc_id

  worker_groups = var.worker_groups

  map_users = var.map_users
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
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
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"         = var.acm_certificate_arn
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