output "cloudfront_origin_access_identity_iam_arns" {
  value = module.cdn.cloudfront_origin_access_identity_iam_arns
}

output "cloudfront_distribution_domain_name" {
  value = module.cdn.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  value = module.cdn.cloudfront_distribution_hosted_zone_id
}
