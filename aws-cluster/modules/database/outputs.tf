resource "local_file" "database_credentials" {
  filename = "${path.root}/outputs/database_credentials.json"
  content  = <<EOF
{
  "database": "${module.db.db_instance_name}",
  "username": "${module.db.db_instance_username}",
  "password": "${module.db.db_instance_password}",
  "port": "${module.db.db_instance_port}",
  "hostname": "${module.db.db_instance_endpoint}"
}
EOF
}
