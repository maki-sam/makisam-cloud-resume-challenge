module "template_files" {
  source   = "hashicorp/dir/template"
  base_dir = var.front_end_dir
}

resource "aws_s3_bucket" "makisam_crc" {
  bucket = "makisam-cloud-resume-challenge-prod"
}

// Upload Frontend Files
resource "aws_s3_object" "front_end_files" {
  bucket   = aws_s3_bucket.makisam_crc.bucket
  for_each = module.template_files.files
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
  etag         = each.value.digests.md5
}


