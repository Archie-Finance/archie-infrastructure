module "archie_testing_container_registry" {
  source = "../container_registry"

  name = "archie-testing"
}

module "vpc" {
  source = "../vpc"

  name         = var.name
  cluster_name = var.cluster_name
}

module "eks" {
  source = "../kubernetes"

  cluster_name = var.cluster_name

  acm_certificate_arn = var.acm_certificate_arn

  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.private_subnets

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.medium"
      additional_userdata  = "stress testing cluster worker"
      asg_desired_capacity = 1
    },
  ]

  map_users = [
    {
      userarn  = module.iam_user_test_cluster_access.iam_user_arn
      username = module.iam_user_test_cluster_access.iam_user_name
      groups   = ["system:masters"]
    },
  ]
}

module "iam_policy_eks_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "TestingClusterEksAccess"
  path        = "/"
  description = "Access to testing cluster EKS"

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

module "iam_policy_ecr_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "TestingClusterEcrAccess"
  path        = "/"
  description = "Access to testing cluster ECR"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "ecr:*",
          "Resource": "${module.archie_testing_container_registry.arn}"
      }
  ]
}
EOF
}

module "iam_policy_ecr_login" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "EcrLogin"
  path        = "/"
  description = "Access get authorization token"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        }
    ]
}
EOF
}

module "iam_user_test_cluster_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "4.14.0"

  name = "TestClusterAccess"
}

resource "aws_iam_user_policy_attachment" "attach_kubernetes_access_policy" {
  user       = module.iam_user_test_cluster_access.iam_user_name
  policy_arn = module.iam_policy_eks_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_ecr_access_policy" {
  user       = module.iam_user_test_cluster_access.iam_user_name
  policy_arn = module.iam_policy_ecr_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_ecr_login_policy" {
  user       = module.iam_user_test_cluster_access.iam_user_name
  policy_arn = module.iam_policy_ecr_login.arn
}
