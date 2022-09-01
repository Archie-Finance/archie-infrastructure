variable "cluster_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_private_subnets" {}

variable "worker_groups" {}

variable "map_users" {}

variable "map_accounts" {
  type = list(string)
  default = []
}