import sys
import json
import platform

BUCKET_NAME = "data-mesh-pwithams-123"
KMS_KEY_ARN = "test"


class UnsupportedPythonVersion(Exception):
    pass


class Boto3PackageMissing(Exception):
    pass


python_major_version = int(platform.python_version().split(".")[0])
if python_major_version < 3:
    raise UnsupportedPythonVersion(
        (
            "The python version should be 3.x - you can change the python executable by setting the python_name variable. "
            "You can also create a bucket manually beforehand, specify the name as a variable, and set automate_bucket_creation = false"
        )
    )


try:
    import boto3
except ImportError:
    raise Boto3PackageMissing(
        (
            "The boto3 python package is required to create Terraform independent S3 bucket. "
            "You can also create a bucket manually beforehand, specify the name as a variable, and set automate_bucket_creation = false"
        )
    )


def set_bucket_encryption(bucket_name, kms_key_arn):
    client = boto3.client("s3")
    response = client.put_bucket_encryption(
        Bucket=bucket_name,
        ServerSideEncryptionConfiguration={
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "aws:kms",
                        "KMSMasterKeyID": kms_key_arn,
                    },
                    "BucketKeyEnabled": True,
                },
            ],
        },
    )


def create_s3_bucket(bucket_name):
    client = boto3.client("s3")
    response = client.create_bucket(
        Bucket=bucket_name,
    )


def main():
    for line in sys.stdin:
        terraform_input = json.loads(line)
        break

    bucket_name = terraform_input["bucket_name"]
    kms_key_arn = terraform_input["kms_key_arn"]

    create_s3_bucket(bucket_name)
    set_bucket_encryption(bucket_name, kms_key_arn)

    result = {"bucket_created": "true"}
    print(json.dumps(result))


main()
