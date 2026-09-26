resource "aws_s3_bucket" "ansible_artifacts" {
  bucket = "${local.name_prefix}-artifacts-${data.aws_caller_identity.current.account_id}"

  # Lab descartável.
  force_destroy = true

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-artifacts"
    Purpose = "AnsibleArtifacts"
  })
}

resource "aws_s3_bucket_public_access_block" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
