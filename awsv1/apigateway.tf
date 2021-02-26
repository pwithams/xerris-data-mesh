# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.resource_prefix}-api"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "${var.resource_prefix}-api"
      version = var.api_version
    }

    paths = {
      (var.post_path) = {
        post = {
          security = [
            {
              sigv4 = []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = module.lambda_sink_data.this_lambda_function_invoke_arn
          }
          requestBody = {
            content = {
              "application/json" = {
                schema = {
                  "$ref" = "#/components/schemas/Body"
                }
              }
            }
          }

        }
      }
    }

    components = {
      securitySchemes = {
        sigv4 = {
          type                         = "apiKey"
          name                         = "Authorization"
          in                           = "header"
          x-amazon-apigateway-authtype = "awsSigv4"
        }
      }
      schemas = {
        Body = {
          type = "object",
          properties = {
            key = {
              type = "string"
            }
          }
        }
      }
    }

  })

}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.api_stage_name
}
