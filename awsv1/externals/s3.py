import boto3
import json

BUCKET_NAME = "data-mesh-pwithams-123"


def set_bucket_encryption():
    client = boto3.client("s3")
    response = client.put_bucket_encryption(
        Bucket=BUCKET_NAME,
        ServerSideEncryptionConfiguration={
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "aws:kms",
                        "KMSMasterKeyID": KMS_KEY_ARN,
                    },
                    "BucketKeyEnabled": True,
                },
            ],
        },
    )
    print("{}")


def create_s3_bucket():
    client = boto3.client("s3")
    response = client.create_bucket(
        Bucket=BUCKET_NAME,
    )
    result = {}
    print(json.dumps(result))


create_s3_bucket()
