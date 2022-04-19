module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.2"

  comment = var.description
  enabled = true

  aliases = [var.domain_name]

  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true

  origin_access_identities = {
    "${var.name}" = var.name
  }

  origin = {
    "${var.name}" = {
      domain_name = module.static_website_bucket.s3_bucket_bucket_domain_name
      s3_origin_config = {
        origin_access_identity = var.name
      }
    }
  }

  default_root_object = "index.html"

  custom_error_response = [{
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }]

  default_cache_behavior = {
    path_pattern           = "/*"
    target_origin_id       = var.name
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

data "aws_iam_policy_document" "static_website_bucket_bucket_policy" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = [module.cdn.cloudfront_origin_access_identity_iam_arns.0]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${var.domain_name}/*"
    ]
  }
}

module "static_website_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.0.1"

  bucket = var.domain_name
  acl    = "public-read"

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  versioning = {
    enabled = true
  }

  attach_policy = true
  force_destroy = true

  policy = data.aws_iam_policy_document.static_website_bucket_bucket_policy.json

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}
