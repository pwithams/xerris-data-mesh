resource "aws_athena_workgroup" "workgroup" {
  name          = "${var.resource_prefix}-workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.bucket_name}/athena_query_results/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn = data.aws_kms_key.s3_key.arn
      }
    }
  }

  tags = var.project_tags
}
