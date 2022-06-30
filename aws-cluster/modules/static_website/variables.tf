variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "alternate_domains" {
  type    = list(string)
  default = []
}

variable "acm_certificate_arn" {
  type = string
}

variable "lambda_function_association" {
  type    = any
  default = {}
}

variable "ignore_cloudfront_aliases" {
  type    = bool
  default = false
}
