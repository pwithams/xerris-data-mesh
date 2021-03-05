# create groups

resource "aws_iam_group" "api_access" {
  name = "${var.resource_prefix}-api-access-group"
  path = "/datamesh/${var.resource_prefix}/"
}

resource "aws_iam_group_policy_attachment" "group_policy_attach" {
  group      = aws_iam_group.api_access.name
  policy_arn = aws_iam_policy.api_access_policy.arn
}

resource "aws_iam_policy" "api_access_policy" {
  name        = "${var.resource_prefix}-api-access-policy"
  path        = "/datamesh/${var.resource_prefix}/"
  description = "Policy that allows API access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["execute-api:Invoke",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*",
        ]
      },
    ]
  })
}

resource "aws_iam_group" "athena_access" {
  name = "${var.resource_prefix}-athena-access-group"
  path = "/datamesh/${var.resource_prefix}/"
}

resource "aws_iam_group_policy_attachment" "athena_group_policy_attach" {
  group      = aws_iam_group.athena_access.name
  policy_arn = aws_iam_policy.athena_access_policy.arn
}

resource "aws_iam_policy" "athena_access_policy" {
  name        = "${var.resource_prefix}-athena-access-policy"
  path        = "/"
  description = "Policy that allows Athena/Glue access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:*",
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "*",
        ]
      },
      {
        Action = [
          "kms:*",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
        ]
        Effect = "Allow"
        Resource = [
          data.aws_kms_key.s3_key.arn,
        ]
      }
    ]
  })
}
