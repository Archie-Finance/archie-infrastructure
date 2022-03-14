module "iam_policy_container_registry_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "GithubActionsContainerRegistryAccess"
  path        = "/"
  description = "Accress to ECR for Github actions"

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
          "Resource": "${resource.aws_ecr_repository.container_repository.arn}"
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
  description = "Accress to EKS for Github actions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "eks:*",
          "Resource": "${module.eks.cluster_arn}"
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

resource "aws_iam_user_policy_attachment" "attach_eks_access_policy" {
  user       = module.iam_user_github_actions.iam_user_name
  policy_arn = module.iam_policy_eks_access.arn
}
