data "external" "example" {
  count   = var.automate_bucket_creation ? 1 : 0
  program = [var.s3_executable_name, var.s3_creation_script]

  query = {
    bucket_name = var.bucket_name
    kms_key_arn = data.aws_kms_key.s3_key.arn
  }
}
