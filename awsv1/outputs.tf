output "firehose_stream_names" {
  value       = values(aws_kinesis_firehose_delivery_stream.firehose)[*].name
  description = "A list of the firehose stream names created"
}

output "glue_table_names" {
  value       = values(aws_glue_catalog_table.data_schema)[*].name
  description = "A list of the glue table names created"
}

output "api_gateway_id" {
  value       = aws_api_gateway_rest_api.api.id
  description = "The API gateway ID"
}

output "api_gateway_deployment_url" {
  value       = aws_api_gateway_deployment.deployment.invoke_url
  description = "The API gateway deployment URL base"
}

output "api_gateway_deployment_url_full" {
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}${trimprefix(var.post_path, "/")}"
  description = "The API gateway deployment URL for posting data to"
}
