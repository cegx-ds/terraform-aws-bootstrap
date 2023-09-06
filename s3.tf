module "s3-bucket" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash in GitHub
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  count                   = var.create_bucket ? 1 : 0
  bucket_prefix           = var.name
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  force_destroy           = var.bucket_force_destroy

  lifecycle_rule = [
    {
      id      = "nf-work"
      enabled = true

      filter = {
        prefix = "nf-work/"
      }

      expiration = {
        days = 14
      }
    },
  ]
}
