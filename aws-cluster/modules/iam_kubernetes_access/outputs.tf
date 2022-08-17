resource "local_file" "iam_user_credentials" {
  filename = "${path.root}/outputs/iam_kuberetes_access_user_credentials.json"
  content  = <<EOF
{
  "iam_user_name": "${module.iam_user_developer_access.iam_user_name}",
  "iam_access_key_id": "${module.iam_user_developer_access.iam_access_key_id}",
  "iam_access_key_secret": "${module.iam_user_developer_access.iam_access_key_secret}",
}
EOF
}

output "developer_access_user_arn" {
  value = module.iam_user_developer_access.iam_user_arn
}

output "developer_access_user_name" {
  value = module.iam_user_developer_access.iam_user_name
}
