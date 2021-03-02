import os
import datetime
import json
import boto3
import cerberus
from utils import logging

STREAM_NAMES = json.loads(os.environ["STREAM_NAMES"])

LOGGING_LEVEL = os.environ.get("LOGGING_LEVEL", "DEBUG")
logger = logging.get_logger(__name__, LOGGING_LEVEL)


def sink_data(event, context):
    del context
    logger.debug(event)
    logger.debug(event["body"])

    try:
        body = json.loads(event["body"])
        schema = body["schema"]
        data = body["data"]
    except KeyError:
        return InvalidBodyResponse().get_response()

    stream_name = get_stream_name(schema, STREAM_NAMES)
    if not stream_name:
        return SchemaDoesNotExistResponse().get_response()

    database_name = get_database_name(schema, STREAM_NAMES)
    schema_columns = get_glue_table_schema(database_name, schema)

    if not data_matches_schema(data, schema_columns):
        return DataSchemaMismatchResponse().get_response()

    logger.debug(STREAM_NAMES)

    success = send_to_firehose(stream_name, data)

    if not success:
        return InternalServerErrorResponse().get_response()

    return SuccessResponse().get_response()


def get_stream_name(schema, streams):
    stream = None
    for firehose_details in streams:
        if firehose_details["table_name"] == schema:
            stream = firehose_details["firehose_name"]
            break
    return stream


def get_database_name(schema, streams):
    stream = None
    for firehose_details in streams:
        if firehose_details["table_name"] == schema:
            stream = firehose_details["database_name"]
            break
    return stream


def convert_type(type_name):
    mappings = {
        "integer": ["int", "bigint", "smallint"],
        "float": ["decimal", "double"],
        "custom_datetime": ["date", "time", "timestamp"],
        "string": ["string", "varchar"],
    }

    for mapping_key in mappings:
        if type_name in mappings[mapping_key]:
            return mapping_key
    raise KeyError(f"Cannot find type match for {type_name}")


def get_constraint_checker(type_name):
    def is_datetime(field, value, error):
        """Allows iso and timestamp strings, as well as integer timestamps."""
        if isinstance(value, datetime.datetime):
            return True

        try:
            datetime.datetime.fromisoformat(value.rstrip("Z"))
            return True
        except ValueError:
            pass

        try:
            datetime.datetime.fromtimestamp(int(value))
            return True
        except ValueError:
            pass

        try:
            datetime.datetime.fromtimestamp(int(value) / 1000)
            return True
        except ValueError:
            pass

        error(field, f"{value} is not a valid iso or timestamp string, or integer timestamp")

    mappings = {
        "custom_datetime": is_datetime,
    }
    if type_name in mappings:
        return mappings[type_name]
    return None


def data_matches_schema(data, schema_columns):
    schema_definition = {}
    for column in schema_columns:
        try:
            type_name = convert_type(column["Type"])
            constraint_checker = get_constraint_checker(type_name)
            if constraint_checker:
                schema_definition[column["Name"]] = {"check_with": constraint_checker}
            else:
                schema_definition[column["Name"]] = {"type": type_name}

        except KeyError as exception:
            logger.debug(exception)
            return False
    print(schema_definition)
    validator = cerberus.Validator(schema_definition)
    for entry in data:
        valid = validator.validate(entry)
        if not valid:
            logger.debug("%s did not validate: %s", entry, validator.errors)
            return False
    return True


def send_to_firehose(stream_name, data):
    records = []
    for record in data:
        records.append(
            {
                "Data": json.dumps(record).encode(),
            }
        )

    client = boto3.client("firehose")
    response = client.put_record_batch(
        DeliveryStreamName=stream_name,
        Records=records,
    )
    print(response)
    return True


def get_glue_table_schema(database_name, table_name):
    client = boto3.client("glue")
    response = client.get_table(
        DatabaseName=database_name,
        Name=table_name,
    )
    return response["Table"]["StorageDescriptor"]["Columns"]


class ApiGatewayResponse:
    def __init__(self):
        self.is_base64_encoded = False
        self.status_code = 200
        self.body = {"success": True, "message": "success"}

    def get_response(self):
        logger.debug("Response type: %s", type(self))
        return {
            "isBase64Encoded": self.is_base64_encoded,
            "statusCode": self.status_code,
            "body": json.dumps(self.body),
        }


class SuccessResponse(ApiGatewayResponse):
    pass


class SchemaDoesNotExistResponse(ApiGatewayResponse):
    def __init__(self):
        super().__init__()
        self.status_code = 400
        error_message = "The specified schema does not exist for this endpoint"
        self.body = {"success": False, "message": error_message}


class InvalidBodyResponse(ApiGatewayResponse):
    def __init__(self):
        super().__init__()
        self.status_code = 400
        error_message = 'The body format should be: {"schema": "schema name", "data": [{"column name": "column value"}'
        self.body = {"success": False, "message": error_message}


class DataSchemaMismatchResponse(ApiGatewayResponse):
    def __init__(self):
        super().__init__()
        self.status_code = 400
        error_message = "The data does not match the schema provided"
        self.body = {"success": False, "message": error_message}


class InternalServerErrorResponse(ApiGatewayResponse):
    def __init__(self):
        super().__init__()
        self.status_code = 500
        error_message = "An error occurred during the data sink process"
        self.body = {"success": False, "message": error_message}
