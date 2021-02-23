module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.resource_prefix}-gateway"
  description   = "My HTTP API Gateway"
  protocol_type = "HTTP"

  create_api_domain_name = false

  # Routes and integrations
  integrations = {
    "GET /" = {
      lambda_arn             = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.resource_prefix}-mainService"
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.resource_prefix}-mainService"
    }
  }

  tags = var.project_tags
}
