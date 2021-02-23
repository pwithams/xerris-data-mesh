# variables with no defaults - must be specified in terraform.tfvars

variable "aws_account_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "lambda_container_full_name" {
  type = string
}

variable "container_tag" { type = string }


# variables with defaults

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_tags" {
  type = object({
    project_name = string
  })

  default = {
    project_name = "data-mesh"
  }
}
