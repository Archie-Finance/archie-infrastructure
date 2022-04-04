output "cloudfront_distribution_domain_name" {
  value = module.cdn.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  value = module.cdn.cloudfront_distribution_hosted_zone_id
}

resource "local_file" "cloudfront_distribution_details" {
  filename = "${path.module}/outputs/cloudfront_distribution_${var.name}.json"
  content  = <<EOF
{
  "cloudfront_id": "${module.cdn.cloudfront_distribution_id}",
  "cloudfront_distribution_domain_name": "${module.cdn.cloudfront_distribution_domain_name}",
  "cloudfront_distribution_hosted_zone_id": "${module.cdn.cloudfront_distribution_hosted_zone_id}",
}
EOF
}

