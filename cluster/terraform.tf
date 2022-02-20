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

resource "digitalocean_kubernetes_cluster" "archie" {
  name    = var.environment-name
  region  = var.do-region
  version = var.do-kubernetes-cluster-version

  node_pool {
    name       = "worker-pool"
    size       = var.do-worker-size
    node_count = 1
  }
}

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.archie.endpoint
  token = digitalocean_kubernetes_cluster.archie.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.archie.kube_config[0].cluster_ca_certificate
  )
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = var.app
    labels = {
      app = var.app
    }
  }
  spec {
    replicas = 3

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
  }
  spec {
    type = "LoadBalancer"

    selector = {
      app = kubernetes_deployment.app.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}
