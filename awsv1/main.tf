terraform {
  backend "s3" {
    bucket = "terraform-backend-state-pwithams"
    key    = "data_mesh/terraform.tf_state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}
