variable "front_end_dir" {
  type    = string
  default = "../front-end/"
}

variable "acm_certificate_arn" {
  type        = string
  description = "Enter the ARN of the ACM certificate to use for CloudFront"
}
