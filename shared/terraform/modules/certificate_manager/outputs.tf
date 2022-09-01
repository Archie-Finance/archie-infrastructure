output "acm_certificate_arn" {
  value = module.acm.acm_certificate_arn
}

# resource "local_file" "certificate_arn" {
#   filename = "${path.root}/outputs/acm_certificate.json"
#   content  = <<EOF
# {
#   "certificate_arn": "${module.acm.acm_certificate_arn}"
# }
# EOF
# }
