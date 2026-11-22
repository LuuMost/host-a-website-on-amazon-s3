terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  website_files = fileset("${path.module}/../website", "**")
  content_types = {
    html = "text/html; charset=utf-8"
    css  = "text/css; charset=utf-8"
    js   = "application/javascript"
    svg  = "image/svg+xml"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    webp = "image/webp"
    ico  = "image/x-icon"
  }
}

resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name

  tags = {
    Project     = "Host a Website on Amazon S3"
    ManagedBy   = "Terraform"
    Environment = "learning"
  }
}

# Modern S3 buckets should not grant access with object ACLs. The public
# website read access below is granted only through the bucket policy.
resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "site_files" {
  for_each = local.website_files

  bucket       = aws_s3_bucket.site.id
  key          = each.value
  source       = "${path.module}/../website/${each.value}"
  source_hash  = filemd5("${path.module}/../website/${each.value}")
  content_type = lookup(local.content_types, lower(element(reverse(split(".", each.value)), 0)), "application/octet-stream")
}

# This intentionally makes the website objects public to read. The explicit
# Deny models the project extension. It applies to everyone, including the
# bucket owner, until this bucket policy is removed.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicReadForWebsite"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      },
      {
        Sid       = "DenyDeleteIndexDocument"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteObject"
        Resource  = "${aws_s3_bucket.site.arn}/index.html"
      }
    ]
  })

  # Ensure bucket-level public-access settings and files are ready before
  # publishing the policy. On destroy, Terraform removes the policy first,
  # allowing its managed index.html object to be deleted during cleanup.
  depends_on = [
    aws_s3_bucket_public_access_block.site,
    aws_s3_bucket_ownership_controls.site,
    aws_s3_object.site_files,
  ]
}
