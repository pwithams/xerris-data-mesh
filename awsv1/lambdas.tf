locals {

  lambda_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "FullAccess",
            "Effect": "Allow",
            "Action": [
                "*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

module "lambda_sink_data" {
  source = "terraform-aws-modules/lambda/aws"


  function_name = "${var.resource_prefix}-sinkData"
  description   = "Handles data ingest"
  handler       = "handlers.handlers.sink_data"
  runtime       = "python3.8"

  source_path = [
    {
      path = "${path.module}/lambdas"
      patterns = [
        "!.*",
        ".*\\.py",
        "!tests/.*",
      ]
    }
  ]

  cloudwatch_logs_retention_in_days = 1
  attach_cloudwatch_logs_policy     = true
  attach_policy_json                = true
  policy_json                       = local.lambda_policy

  environment_variables = {
    STREAM_NAMES = jsonencode(
      [for g in aws_kinesis_firehose_delivery_stream.firehose : {
        firehose_name = g.name,
        database_name = g.extended_s3_configuration[0].data_format_conversion_configuration[0].schema_configuration[0].database_name,
        table_name    = g.extended_s3_configuration[0].data_format_conversion_configuration[0].schema_configuration[0].table_name,
        }
      ]
    )
  }

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*",
    }
  }

  layers = [
    module.lambda_layer_local.this_lambda_layer_arn,
  ]

  publish = true

  tags = var.project_tags
}

module "lambda_layer_local" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "${var.resource_prefix}-lambdaLayer"
  description         = "Layer for Lambda"
  compatible_runtimes = ["python3.8"]
  runtime             = "python3.8"

  source_path = [
    {
      path             = "${path.module}/lambdas/layer",
      pip_requirements = true
      prefix_in_zip    = "python/lib/python3.8/site-packages",
    }
  ]

  tags = var.project_tags
}
