resource "aws_glue_catalog_database" "glue_database" {
  name = replace("${var.resource_prefix}-database", "-", "_")
}

resource "aws_glue_crawler" "data_crawler" {
  for_each      = var.schemas
  database_name = aws_glue_catalog_database.glue_database.name
  name          = "${var.resource_prefix}-data-crawler-${each.value.schema_name}"
  role          = aws_iam_role.glue_role.arn
  schedule      = "cron(5 * * * ? *)"

  catalog_target {
    database_name = aws_glue_catalog_database.glue_database.name
    tables        = [aws_glue_catalog_table.data_schema[each.key].name]
  }

  schema_change_policy {
    delete_behavior = "LOG"
  }

  tags = var.project_tags
}


resource "aws_glue_catalog_table" "data_schema" {
  for_each      = var.schemas
  name          = replace(each.value.schema_name, "-", "_")
  database_name = aws_glue_catalog_database.glue_database.name

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location = "s3://${var.bucket_name}/${var.data_path}/${each.value.schema_name}/"

    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    dynamic "columns" {
      for_each = each.value.schema_details
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }
}


resource "aws_iam_role" "glue_role" {
  name               = "${var.resource_prefix}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json
  tags = var.project_tags
}

data "aws_iam_policy_document" "glue_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "glue_custom_policy" {
  name   = "${var.resource_prefix}-glue_custom_policy"
  role   = aws_iam_role.glue_role.name
  policy = data.aws_iam_policy_document.glue_custom_policy.json
}

data "aws_iam_policy_document" "glue_custom_policy" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
  }

  statement {
    actions = [
      "kms:*",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]

    resources = [
      data.aws_kms_key.s3_key.arn,
    ]
  }
}

data "aws_iam_policy" "glue_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = data.aws_iam_policy.glue_service_role.arn
}

