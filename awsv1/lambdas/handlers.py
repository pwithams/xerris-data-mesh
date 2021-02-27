import os
import datetime
import json
import boto3

STREAM_NAME = os.environ["STREAM_NAME"]


def sink_data(event, context):
    print(event)
    print(event["body"])

    data = [
        {
            "id": 1,
            "name": "test",
            "value": 123.45,
            "timestamp": datetime.datetime.now().isoformat() + "Z",
        }
    ]

    send_to_firehose(data)

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": '{"success": true}',
    }


def send_to_firehose(data):
    records = []
    for record in data:
        records.append(
            {
                "Data": json.dumps(record).encode(),
            }
        )

    client = boto3.client("firehose")
    response = client.put_record_batch(
        DeliveryStreamName=STREAM_NAME,
        Records=records,
    )
    print(response)
