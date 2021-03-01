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

variable "project_name" {
  type = string
}


# variables with defaults

variable "table_info" {
  type = map(any)

  default = {
    t1 = {
      table_name = "id1"
      column_details = [
        {
          name = "name"
          type = "string"
        },
        {
          name = "value"
          type = "double"
        }
      ]
    },
    t2 = {
      table_name = "id2"
      column_details = [
        {
          name = "name"
          type = "string"
        },
        {
          name = "value"
          type = "double"
        }
      ]

    },
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "post_path" {
  type    = string
  default = "/sink_data/"
}

variable "api_version" {
  type    = string
  default = "1.0"
}

variable "api_stage_name" {
  type    = string
  default = "datamesh"
}

variable "data_path" {
  type    = string
  default = "data"
}

variable "project_tags" {
  type = object({
    project_name = string
  })

  default = {
    project_name = "data-mesh"
  }
}
