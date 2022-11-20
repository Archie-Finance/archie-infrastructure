variable "name" {
  type = string
  default = "archie-testing"
}

variable "cluster_name" {
  type = string
  default = "archie-testing-cluster"
}

variable "acm_certificate_arn" {
  type = string
}