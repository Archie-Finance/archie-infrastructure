# resource "local_file" "iam_user_credentials" {
#   filename = "${path.root}/outputs/iam_user_credentials.json"
#   content  = <<EOF
# {
#   "iam_user_name": "${module.iam_user_github_actions.iam_user_name}",
#   "iam_access_key_id": "${module.iam_user_github_actions.iam_access_key_id}",
#   "iam_access_key_secret": "${module.iam_user_github_actions.iam_access_key_secret}",
# }
# EOF
# }

# resource "local_file" "iam_aws_ingress_controller" {
#   filename = "${path.root}/outputs/iam_aws_ingress_controller.json"
#   content  = <<EOF
# {
#   "iam_policy_arn": "${module.iam_policy_aws_ingress_controller_access.arn}"
# }
# EOF
# }

output "github_actions_user_arn" {
  value = module.iam_user_github_actions.iam_user_arn
}

output "github_actions_user_name" {
  value = module.iam_user_github_actions.iam_user_name
}
