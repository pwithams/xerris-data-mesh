resource "aws_glue_catalog_database" "glue_database" {
  name = replace("${var.resource_prefix}-database", "-", "_")
}

resource "aws_glue_crawler" "data_crawler" {
  database_name = aws_glue_catalog_database.glue_database.name
  name          = "${var.resource_prefix}-data-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.bucket_name}/${var.data_path}/"
  }
}


resource "aws_glue_catalog_table" "data_schema" {
  name          = replace("${var.resource_prefix}-schema", "-", "_")
  database_name = aws_glue_catalog_database.glue_database.name

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {

    columns {
      name = "id"
      type = "int"
    }

    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "value"
      type = "double"
    }

    columns {
      name = "ts"
      type = "timestamp"
    }

  }
}


resource "aws_iam_role" "glue_role" {
  name               = "${var.resource_prefix}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json
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
}

data "aws_iam_policy" "glue_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = data.aws_iam_policy.glue_service_role.arn
}

