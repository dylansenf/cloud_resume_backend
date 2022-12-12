terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4TWN6IRUWJAXA47J"
  secret_key = "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"
}

# create an EC2 instance
# resource "aws_instance" "web" {
#   ami           = "ami-0b0dcb5067f052a63"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "EC2 Terraform Instance"
#     Environment = "dev"
#   }
# }

# S3 Static Website

# create bucket
resource "aws_s3_bucket" "site" {
bucket = "lab-10-dylan-senf"
}


# set ACL (access control list)
resource "aws_s3_bucket_acl" "site_bucket_acl" {
  bucket = aws_s3_bucket.site.id
  acl    = "public-read"
}

#create S3 bucket policy to get (read) objects
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}

#create S3 website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.site.id
  index_document {
    suffix = "index.html"
  }
}

# the website endpoint URL after creating the bucket
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

# upload index.html to S3 bucket
resource "aws_s3_object" "index" {
  bucket    = aws_s3_bucket.site.id
  key       = "index.html"
  source    = "${path.module}/../assets/index.html"
  etag      = filemd5("${path.module}/../assets/index.html")
  acl       = "public-read"
  content_type = "text/html"
} 
