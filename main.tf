provider "aws" {
  region = "us-east-1"  # Using the us-east-1 region
}

resource "aws_s3_bucket" "awesome_bucket" {
  bucket = "first-awesome-bucket"  # Changed to "first awesome bucket"

  tags = {
    Name        = "First Awesome Bucket"
    Environment = "Dev"
    Project     = "Awesome Project"
    Owner       = "Your Name"  # Change this as needed
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.awesome_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.awesome_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          "${aws_s3_bucket.awesome_bucket.arn}/*",
          aws_s3_bucket.awesome_bucket.arn
        ]
        Condition = {
          "IpAddress" = {
            "aws:SourceIp" = [
              "190.0.0.0/8",  # Example CIDR range for Bolivia
              "191.96.0.0/16" # Adjust according to actual IP ranges
            ]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "my_bucket_public_access" {
  bucket = aws_s3_bucket.awesome_bucket.id

  block_public_acls = true
  ignore_public_acls = true
}
