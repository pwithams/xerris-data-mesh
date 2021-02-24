def handler(event, context):
    print(event)

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": None,
        "body": {
            "success": True,
        },
    }
