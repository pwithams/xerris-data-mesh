# Xerris Data Mesh

This module creates the basic underlying infrastructure to allow easy, serverless, and scalable AWS data ingestion and storage that can be queried using Athena.

## Requirements

### Before deployment

The following are required before deploying this module:
 - an AWS account
 - CLI user credentials with permission to deploy the specified resources

### After deployment

Once deployed, the following are required:
 - To post data to the endpoint:
     - CLI user credentials that have been added to the API gateway group created

 - To run queries from Athena:
     - a user that has been added to the Athena access group created

## Usage

```hcl
module "xerris_data_mesh" {
  source = "github.com/pwithams/xerris-data-mesh/awsv1"

    # general project information
    aws_account_id  = "353831065989"
    resource_prefix = "data-mesh-dev"
    stage           = "dev"
    project_name    = "datameshv1"

    # s3 details
    bucket_name     = "data-mesh-pwithams-123"
    automate_bucket_creation = true

    # one or more schemas to support
    schemas = {
      schema1 = {
        schema_name = "data_product1"
        schema_details = [
          {
            name = "id"
            type = "int"
          },
          {
            name = "value"
            type = "double"
          }
        ]
      },
      schema2 = {
        schema_name = "data_product2"
        schema_details = [
          {
            name = "id"
            type = "int"
          },
          {
            name = "name"
            type = "string"
          },
          {
            name = "ts"
            type = "timestamp"
          }
        ]
      },
    }
}
```

## Posting data to the endpoint

Once deployed, you can test out the deployment by using a tool such as Postman to send a test payload.

Assuming the schemas above were specified, an example payload could be:

```
{
    "schema": "data_product2",
    "data": [
        {
            "id": 2,
            "name": "test",
            "ts": "1614841811000"
        }
    ]
}
```

Sent as a POST request sent to your endpoint, similar to `https://[api gateway id].execute-api.us-east-1.amazonaws.com/sink_data/`

## Authentication

IAM credentials are used for authentication, so assuming your credentials either have the required permissions or have been added to the API access group, you can add them under the Authorization section of Postman, under AWS Signature.

If you're using a programming language, you can either sign the request yourself or use a helper module, such as https://pypi.org/project/aws-requests-auth/

For more details about signing requests, see https://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html

## Architecture

![Architecture](docs/architecture.png)
