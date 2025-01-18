resource "aws_cloudfront_distribution" "iac-cf" {
  aliases             = ["resume.the-art-by-makisam.cloud"]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = true
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = aws_s3_bucket.makisam_crc.id
    viewer_protocol_policy = "redirect-to-https"
  }
  origin {
    domain_name              = aws_s3_bucket.makisam_crc.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.makisam_crc.id
    origin_access_control_id = aws_cloudfront_origin_access_control.makisam-oac.id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "makisam-oac" {
  name                              = "makisam-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "cf-oac-access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.makisam_crc.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.iac-cf.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cf-oac-policy" {
  bucket = aws_s3_bucket.makisam_crc.bucket
  policy = data.aws_iam_policy_document.cf-oac-access.json

}