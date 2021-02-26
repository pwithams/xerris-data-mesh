def sink_data(event, context):
    print(event)
    print(event["body"])

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": '{"success": true}',
    }
