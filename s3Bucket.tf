resource "random_id" "s3_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "webappbucket" {
  bucket = "bucket${random_id.s3_bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "bucket${random_id.s3_bucket_id.hex}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "webappbucket_sse" {
  bucket = aws_s3_bucket.webappbucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "webappbucket_lifecycle" {
  bucket = aws_s3_bucket.webappbucket.bucket

  rule {
    id     = "TransitionToStandardIA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
