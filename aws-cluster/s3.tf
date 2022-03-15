
data "aws_iam_policy_document" "marketing_website_bucket_policy" {
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
      "arn:aws:s3:::${var.domain}/*"
    ]
  }
}

module "marketing_website_bucket" {
  # TODO: Update this when proper release is done
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=fix-tf-provider-v4"

  bucket = var.domain
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

  policy = data.aws_iam_policy_document.marketing_website_bucket_policy.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
