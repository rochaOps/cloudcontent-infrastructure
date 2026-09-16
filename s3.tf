# -----------------------------------------------------------------------------
# Free content
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "free_content" {
  bucket = "cloudcontent-free-content-${data.aws_caller_identity.current.account_id}"

  # Laboratory/portfolio teardown.
  force_destroy = true

  tags = merge(local.common_tags, {
    Name        = "cloudcontent-free-content"
    ContentTier = "Free"
  })
}

resource "aws_s3_bucket_public_access_block" "free_content" {
  bucket = aws_s3_bucket.free_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "free_content" {
  bucket = aws_s3_bucket.free_content.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "free_content" {
  bucket = aws_s3_bucket.free_content.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "free_content" {
  bucket = aws_s3_bucket.free_content.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# -----------------------------------------------------------------------------
# Premium content
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "premium_content" {
  bucket = "cloudcontent-premium-content-${data.aws_caller_identity.current.account_id}"

  # Laboratory/portfolio teardown.
  force_destroy = true

  tags = merge(local.common_tags, {
    Name        = "cloudcontent-premium-content"
    ContentTier = "Premium"
  })
}

resource "aws_s3_bucket_public_access_block" "premium_content" {
  bucket = aws_s3_bucket.premium_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "premium_content" {
  bucket = aws_s3_bucket.premium_content.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "premium_content" {
  bucket = aws_s3_bucket.premium_content.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "premium_content" {
  bucket = aws_s3_bucket.premium_content.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}