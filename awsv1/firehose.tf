resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  for_each    = var.schemas
  name        = "${var.resource_prefix}-firehose-stream-${each.value.schema_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = "arn:aws:s3:::${var.bucket_name}"

    prefix              = "${var.data_path}/${each.value.schema_name}/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "${var.data_path}/error/${each.value.schema_name}/!{firehose:error-output-type}/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

    # Must be at least 64
    buffer_size = 128

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_table.data_schema[each.key].database_name
        role_arn      = aws_iam_role.firehose_role.arn
        table_name    = aws_glue_catalog_table.data_schema[each.key].name
      }
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "${var.resource_prefix}-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_policy.json
}

data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }

}

resource "aws_iam_role_policy" "firehose_custom_policy" {
  name   = "${var.resource_prefix}-firehose-custom-policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.firehose_custom_policy.json
}

data "aws_iam_policy_document" "firehose_custom_policy" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
  }
}

data "aws_iam_policy" "firehose_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "firehose_service_role_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = data.aws_iam_policy.firehose_service_role.arn
}

