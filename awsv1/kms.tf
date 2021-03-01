data "aws_kms_key" "s3_key" {
  key_id = "alias/aws/s3"
}
