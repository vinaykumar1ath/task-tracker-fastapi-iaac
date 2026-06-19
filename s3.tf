data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "task_tracker_fastapi" {
  region = var.project.region
  bucket = format("%s-%s-%s-an",var.project.name, data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  bucket_namespace = "account-regional"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "task_tracker_fastapi_restrict_public_access" {
  bucket = aws_s3_bucket.task_tracker_fastapi.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

output "s3_bucket_name" {
  value = aws_s3_bucket.task_tracker_fastapi.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.task_tracker_fastapi.arn
}
