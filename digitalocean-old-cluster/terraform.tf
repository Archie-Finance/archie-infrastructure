terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do-token
}

resource "digitalocean_vpc" "archie" {
  name   = var.environment-name
  region = var.do-region
}

resource "digitalocean_kubernetes_cluster" "archie" {
  name     = var.environment-name
  region   = var.do-region
  version  = var.do-kubernetes-cluster-version
  vpc_uuid = digitalocean_vpc.archie.id

  node_pool {
    name       = "worker-pool"
    size       = var.do-worker-size
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5
  }
}

resource "digitalocean_domain" "lukafurlan-domain" {
  name = var.domain
}

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.archie.endpoint
  token = digitalocean_kubernetes_cluster.archie.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.archie.kube_config[0].cluster_ca_certificate
  )
}

resource "kubernetes_deployment" "archie" {
  metadata {
    name = var.app
    labels = {
      app = var.app
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app
      }
    }
    template {
      metadata {
        labels = {
          app = var.app
        }
      }
      spec {
        container {
          image = var.docker-image
          name  = var.app
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = var.app
    labels = {
      app = var.app
    }
    annotations = {
      "service.beta.kubernetes.io/do-loadbalancer-protocol"                 = "https"
      "service.beta.kubernetes.io/do-loadbalancer-certificate-id"           = digitalocean_certificate.domain-certificate.uuid
      "service.beta.kubernetes.io/do-loadbalancer-tls-ports"                = "443"
      "service.beta.kubernetes.io/do-loadbalancer-redirect-http-to-https"   = "true"
      "service.beta.kubernetes.io/do-loadbalancer-enable-backend-keepalive" = "true"
    }
  }
  spec {
    type = "LoadBalancer"

    selector = {
      app = kubernetes_deployment.archie.metadata.0.labels.app
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 80
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

resource "digitalocean_record" "lukafurlan-domain" {
  domain = digitalocean_domain.lukafurlan-domain.name
  name   = "@"
  type   = "A"
  ttl    = 30
  value  = kubernetes_service.api.status[0].load_balancer[0].ingress[0].ip
}

resource "digitalocean_certificate" "domain-certificate" {
  name    = "api-cert"
  type    = "lets_encrypt"
  domains = [var.domain]
}

output "LoadBalancer_IP" {
  value = kubernetes_service.api.status[0].load_balancer[0].ingress[0].ip
}

output "Certificate_ID" {
  value = digitalocean_certificate.domain-certificate.uuid
}
