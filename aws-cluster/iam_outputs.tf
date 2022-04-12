# # output "iam_policy_container_registry_access_arn" {
# #   description = "ARN for Github actions container registry"
# #   value       = module.iam_policy_container_registry_access.arn
# # }

# # output "iam_policy_eks_access_arn" {
# #   description = "ARN for Github actions eks"
# #   value       = module.iam_policy_eks_access.arn
# # }

# # output "iam_user_github_actions_arn" {
# #   description = "ARN for Github actions IAM user"
# #   value       = module.iam_user_github_actions.iam_user_arn
# # }

# # output "iam_user_github_actions_user_name" {
# #   description = "User name of Github actions IAM user"
# #   value       = module.iam_user_github_actions.iam_user_name
# # }

# # output "iam_user_github_actions_access_key_id" {
# #   description = "IAM Access Key ID for Github actions IAM user"
# #   value       = module.iam_user_github_actions.iam_access_key_id
# # }

# # output "iam_user_github_actions_access_key_secret" {
# #   description = "IAM Access Key Secret for Github actions IAM user"
# #   value       = nonsensitive(module.iam_user_github_actions.iam_access_key_secret)
# # }

# resource "local_file" "iam_user_credentials" {
#   filename = "${path.module}/outputs/iam_user_credentials.json"
#   content  = <<EOF
# {
#   "iam_user_name": "${module.iam_user_github_actions.iam_user_name}",
#   "iam_access_key_id": "${module.iam_user_github_actions.iam_access_key_id}",
#   "iam_access_key_secret": "${module.iam_user_github_actions.iam_access_key_secret}",
# }
# EOF
# }

