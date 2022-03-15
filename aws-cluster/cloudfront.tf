module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.2"

  comment = "Marketing website"
  enabled = true

  aliases = [var.domain]

  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true

  origin_access_identities = {
    marketing_website = "marketing_website"
  }

  origin = {
    marketing_website = {
      domain_name = module.marketing_website_bucket.s3_bucket_bucket_domain_name
      s3_origin_config = {
        origin_access_identity = "marketing_website"
      }
    }
  }

  default_root_object = "index.html"

  custom_error_response = [{
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }]

  default_cache_behavior = {
    path_pattern           = "/*"
    target_origin_id       = "marketing_website"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}
