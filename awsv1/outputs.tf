output "firehose_stream_names" {
  value = values(aws_kinesis_firehose_delivery_stream.firehose)[*].name
  description = "A list of the firehose stream names created"
}

output "glue_table_names" {
  value = values(aws_glue_catalog_table.data_schema)[*].name
  description = "A list of the glue table names created"
}
