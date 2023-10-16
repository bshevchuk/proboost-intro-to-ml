module "s3_assets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket_prefix       = "assets-${var.environment}-"
  acl                 = "private"
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  force_destroy       = true

  cors_rule = [ # https://labelstud.io/guide/persistent_storage#Configure-CORS-for-the-S3-bucket
    {
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers = [
        "x-amz-server-side-encryption",
        "x-amz-request-id",
        "x-amz-id-2"
      ]
      max_age_seconds = 3000
    }
  ]

  versioning = {
    enabled = false #do we need versioning?
  }
}