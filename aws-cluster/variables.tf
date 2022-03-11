variable "region" {
  default     = "us-east-1"
  description = "Aws cluster region"
}

variable "name" {
  default = "archie-development"
}

variable "cluster_name" {
  default = "archie-development-cluster"
}

variable "domain_zone_id" {
  default = "Z02811371LL6FBZYKU5LO"
}

variable "domain" {
  default = "dev.archie.finance"
}
