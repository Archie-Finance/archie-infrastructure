resource "aws_kms_key" "encryption_key" {
  description = "Vault backup encryption key"
}

module "vault_backup_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.5.0"

  bucket = var.vault_backup_bucket_name
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.encryption_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


module "vault_backup_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  depends_on = [
    module.vault_backup_bucket
  ]

  name        = "VaultBackupS3Access"
  path        = "/"
  description = "Access to S3 for Vault backup"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": ["arn:aws:s3:::${var.vault_backup_bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.vault_backup_bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl"
      ],
      "Resource": ["arn:aws:s3:::${var.vault_backup_bucket_name}"]
    }
  ]
}
EOF
}

module "iam_user_vault_backup" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "4.14.0"

  name = "VaultBackupAccess"
}

resource "aws_iam_user_policy_attachment" "attach_vault_backup_iam_policy" {
  user       = module.iam_user_vault_backup.iam_user_name
  policy_arn = module.vault_backup_iam_policy.arn

  depends_on = [
    module.vault_backup_iam_policy
  ]
}
