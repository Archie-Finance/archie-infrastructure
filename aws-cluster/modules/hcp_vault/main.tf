provider "aws" {
  region = var.region
}

resource "hcp_hvn" "hcp_vault_hvn" {
  hvn_id         = var.hvn_id
  cloud_provider = var.cloud_provider
  region         = var.region
}

resource "hcp_vault_cluster" "hcp_vault_cluster" {
  hvn_id          = hcp_hvn.hcp_vault_hvn.hvn_id
  cluster_id      = var.cluster_id
  tier            = var.tier
  public_endpoint = var.enable_public_endpoint
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id          = hcp_hvn.hcp_vault_hvn.hvn_id
  peering_id      = var.peering_id
  peer_vpc_id     = var.peer_vpc_id
  peer_account_id = var.peer_account_id
  peer_vpc_region = var.region
}

resource "hcp_hvn_route" "peer_route" {
  hvn_link         = hcp_hvn.hcp_vault_hvn.self_link
  hvn_route_id     = var.route_id
  destination_cidr = var.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}
