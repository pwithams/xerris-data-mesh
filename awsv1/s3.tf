data "external" "example" {
  count   = var.automate_bucket_creation ? 1 : 0
  program = [var.python_name, "${path.module}/create_s3_bucket.py"]

  query = {
    bucket_name = var.bucket_name
    kms_key_arn = data.aws_kms_key.s3_key.arn
  }
}
