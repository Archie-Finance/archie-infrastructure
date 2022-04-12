module "iam_policy_container_registry_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "GithubActionsContainerRegistryAccess"
  path        = "/"
  description = "Access to ECR for Github actions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
              "ecr:BatchGetImage",
              "ecr:BatchCheckLayerAvailability",
              "ecr:CompleteLayerUpload",
              "ecr:DescribeImages",
              "ecr:DescribeRepositories",
              "ecr:GetDownloadUrlForLayer",
              "ecr:InitiateLayerUpload",
              "ecr:ListImages",
              "ecr:PutImage",
              "ecr:UploadLayerPart"
          ],
          "Resource": "${var.ecr_arn}"
      },
      {
          "Sid": "VisualEditor1",
          "Effect": "Allow",
          "Action": [
              "ecr:GetRegistryPolicy",
              "ecr:GetAuthorizationToken"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

module "iam_policy_eks_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "GithubActionsEksAccess"
  path        = "/"
  description = "Access to EKS for Github actions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "eks:*",
          "Resource": "${var.eks_cluster_arn}"
      }
  ]
}
EOF
}

module "iam_policy_s3_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "GithubActionsS3Access"
  path        = "/"
  description = "Access to S3 for Github actions"

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
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

module "iam_policy_cloudfront_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "GithubActionsCloudFrontAccess"
  path        = "/"
  description = "Access to cloudfront for Github actions"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "cloudfront:CreateInvalidation",
            "Resource": "*"
        }
    ]
}
  EOF
}

module "iam_user_github_actions" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "4.14.0"

  name = "GithubActionsAccess"
}

resource "aws_iam_user_policy_attachment" "attach_container_registry_access_policy" {
  user       = module.iam_user_github_actions.iam_user_name
  policy_arn = module.iam_policy_container_registry_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_s3_access_policy" {
  user       = module.iam_user_github_actions.iam_user_name
  policy_arn = module.iam_policy_s3_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_eks_access_policy" {
  user       = module.iam_user_github_actions.iam_user_name
  policy_arn = module.iam_policy_eks_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_cloudfront_access_policy" {
  user       = module.iam_user_github_actions.iam_user_name
  policy_arn = module.iam_policy_cloudfront_access.arn
}
