locals {
  script_path = var.s3_creation_script == "" ? "${path.module}/create_s3_bucket.py" : var.s3_creation_script
}

data "external" "example" {
  count   = var.automate_bucket_creation ? 1 : 0
  program = [var.s3_executable_name, local.script_path]

  query = {
    bucket_name = var.bucket_name
    kms_key_arn = data.aws_kms_key.s3_key.arn
  }
}
