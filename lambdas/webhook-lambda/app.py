import os
import boto3
import json
import logging
import time


ssm_github_secret_path = os.getenv("SSM_GITHUB_SECRET_PATH")


def handler(event, context):
    ssm_client = boto3.client('ssm')
    redirect_uri = ssm_client.get_parameter(
        Name=ssm_github_secret_path,
        WithDecryption=False
    )['Parameter']['Value']
    print(event)

    return {
        "statusCode": 200,
        "headers": {
            "Cache-Control": "max-age=3600"
        }
    }
