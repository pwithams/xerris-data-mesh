locals {

  lambda_container_full_uri = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.lambda_container_full_name}:${var.container_tag}"

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

module "lambda_service" {
  source = "terraform-aws-modules/lambda/aws"

  function_name        = "${var.resource_prefix}-mainService"
  description          = "Main lambda"
  image_config_command = ["handlers.handler"]

  environment_variables = {
    STREAM_NAME = "test"
  }

  memory_size = 512
  timeout     = 20

  create_package = false

  image_uri    = local.lambda_container_full_uri
  package_type = "Image"

  attach_cloudwatch_logs_policy = true
  attach_policy_json            = true
  policy_json                   = local.lambda_policy

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${module.api_gateway.this_apigatewayv2_api_id}/*/*/*"
    }
  }

  publish = true

  tags = var.project_tags
}
