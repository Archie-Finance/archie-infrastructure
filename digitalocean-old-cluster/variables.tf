variable "environment-name" {
  type    = string
  default = "archie-dev"
}

variable "do-token" {
  type    = string
  default = "36a6e3b3cd390800e0f0eef830fe3528352d5495f2204001853602af556c38a2"
}

variable "do-region" {
  type    = string
  default = "fra1"
}

variable "do-worker-size" {
  type    = string
  default = "s-1vcpu-2gb"
}

variable "do-kubernetes-cluster-version" {
  type    = string
  default = "1.21.9-do.0"
}

variable "docker-image" {
  type    = string
  default = "archieluka/archie-backend:latest"
}

variable "app" {
  type    = string
  default = "archie-backend"
}

variable "domain" {
  type = string
  default = "lukafurlan.net"
}
