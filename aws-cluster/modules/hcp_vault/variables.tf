variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "archie-hvn"
}

variable "cluster_id" {
  description = "The ID of the HCP Vault cluster."
  type        = string
}

variable "peering_id" {
  description = "The ID of the HCP peering connection."
  type        = string
}

variable "route_id" {
  description = "The ID of the HCP HVN route."
  type        = string
}

variable "region" {
  description = "The region of the HCP HVN and Vault cluster."
  type        = string
  default     = "us-east-1"
}

variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Vault cluster."
  type        = string
  default     = "aws"
}

variable "tier" {
  description = "Tier of the HCP Vault cluster. Valid options for tiers."
  type        = string
  default     = "dev"
}

variable "enable_public_endpoint" {
  type    = bool
  default = false
}

variable "peer_vpc_id" {
  type = string
}

variable "peer_account_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}