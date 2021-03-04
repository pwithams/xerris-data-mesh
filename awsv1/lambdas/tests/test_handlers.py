import unittest
from unittest import mock
import os
import datetime
import json

try:
    from handlers import handlers
except KeyError:
    os.environ[
        "STREAM_NAMES"
    ] = '[{"firehose_name":"data-mesh-dev-firehose-stream-data_product1","table_name":"data_product1", "database_name":"test1"},{"firehose_name":"data-mesh-dev-firehose-stream-data_product2","table_name":"data_product2", "database_name":"test2"}]'
    from handlers import handlers


class TestHandlers(unittest.TestCase):
    def setUp(self):
        self.firehose_send_mock = mock.MagicMock()
        handlers.send_to_firehose = self.firehose_send_mock
        self.get_glue_table_mock = mock.MagicMock()
        handlers.get_glue_table_schema = self.get_glue_table_mock

    def test_handler(self):
        schema_definition = [
            {
                "Name": "id",
                "Type": "int",
            },
            {
                "Name": "name",
                "Type": "string",
            },
            {
                "Name": "value",
                "Type": "decimal",
            },
            {
                "Name": "timestamp",
                "Type": "timestamp",
            },
        ]
        glue_mock = mock.MagicMock(return_value=schema_definition)
        handlers.get_glue_table_schema = glue_mock

        schema = "data_product1"
        firehose = "data-mesh-dev-firehose-stream-data_product1"
        data = [
            {
                "id": 1,
                "name": "test",
                "value": 123.45,
                "timestamp": datetime.datetime.now().isoformat() + "Z",
            }
        ]

        test_event = {"body": json.dumps({"schema": schema, "data": data})}

        handlers.sink_data(test_event, None)
        expected_call = mock.call(firehose, data)
        self.firehose_send_mock.assert_has_calls([expected_call])

    def test_handler_string_timestamp(self):
        schema_definition = [
            {
                "Name": "id",
                "Type": "int",
            },
            {
                "Name": "timestamp",
                "Type": "timestamp",
            },
        ]
        glue_mock = mock.MagicMock(return_value=schema_definition)
        handlers.get_glue_table_schema = glue_mock

        schema = "data_product1"
        firehose = "data-mesh-dev-firehose-stream-data_product1"
        data = [
            {
                "id": 1,
                "timestamp": "1614669049",
            }
        ]

        test_event = {"body": json.dumps({"schema": schema, "data": data})}

        handlers.sink_data(test_event, None)
        expected_call = mock.call(firehose, data)
        self.firehose_send_mock.assert_has_calls([expected_call])

    def test_handler_invalid_schema(self):
        schema_definition = [
            {
                "Name": "id",
                "Type": "int",
            },
            {
                "Name": "timestamp",
                "Type": "timestamp",
            },
        ]
        glue_mock = mock.MagicMock(return_value=schema_definition)
        handlers.get_glue_table_schema = glue_mock

        schema = "data_product1"
        firehose = "data-mesh-dev-firehose-stream-data_product1"
        data = [
            {
                "id": 1,
                "timestamp": "2020/1/1",
            }
        ]

        test_event = {"body": json.dumps({"schema": schema, "data": data})}

        handlers.sink_data(test_event, None)
        self.assertEqual(len(self.firehose_send_mock.mock_calls), 0)
