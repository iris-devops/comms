// ##################################################################################
// # Public Bucket - Hosts Webclient
// ##################################################################################

// resource "aws_s3_bucket" "reach-app" {
//   bucket = local.s3_bucket_app
//   tags = merge(local.common_tags, {Product = "reach-s3" })
// }

// resource "aws_s3_bucket_acl" "reach-app-acl" {
//   bucket = aws_s3_bucket.reach-app.id
//   acl    = "public-read"
// }

// resource "aws_s3_bucket_website_configuration" "reach-app-website" {
//   bucket = aws_s3_bucket.reach-app.bucket

//   index_document {
//     suffix = "index.html"
//   }

//   error_document {
//     key = "index.html"
//   }
// }

// resource "aws_s3_bucket_cors_configuration" "reach-app-cors" {
//   bucket = aws_s3_bucket.reach-app.bucket
  
//   cors_rule {
//     allowed_headers = ["*"]
//     allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
//     allowed_origins = ["*"]
//     max_age_seconds = 0
//     expose_headers  = []
//   }
// }
