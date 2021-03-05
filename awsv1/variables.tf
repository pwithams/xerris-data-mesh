# variables with no defaults - must be specified in terraform.tfvars

variable "bucket_name" {
  type        = string
  description = "The S3 bucket where the data will be stored, as well as query results"
}

variable "stage" {
  type        = string
  description = "Indicates which stage the deployment is for, such as dev or prod"
}

variable "resource_prefix" {
  type        = string
  description = "The prefix for all resource names to allow them to be easily identified"
}

variable "project_name" {
  type        = string
  description = "The unique name for this deployment"
}

variable "schemas" {
  type = map(object({
    schema_name = string
    schema_details = list(
      object({
        name = string
        type = string
      })
    )
    })
  )
  description = "A map of schemas to support - each will create its own glue table and firehose stream"
}


# variables with defaults

variable "post_path" {
  type        = string
  default     = "/sink_data/"
  description = "The path used by the API gateway endpoint"
}

variable "api_version" {
  type        = string
  default     = "1.0"
  description = "The current API gateway version"
}

variable "api_stage_name" {
  type        = string
  default     = "datamesh"
  description = "The name for the main API gateway stage"
}

variable "data_path" {
  type        = string
  default     = "data"
  description = "The prefix used for the data stored in S3"
}

variable "automate_bucket_creation" {
  type        = bool
  default     = false
  description = "Can be enabled to use a python script to automatically create an S3 bucket not managed by Terraform"
}

variable "python_name" {
  type        = string
  default     = "python"
  description = "The python executable name to use - may need to be set as python3 in some cases"
}

variable "project_tags" {
  type = object({
    project_name = string
  })

  default = {
    project_name = "data-mesh"
  }
}
