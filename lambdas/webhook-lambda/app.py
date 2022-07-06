import os
import boto3
import json
import logging
import time
import hmac
import base64


ssm_github_secret_path = os.getenv("SSM_GITHUB_SECRET_PATH")


def handler(event, context):
    try:
        ssm_client = boto3.client('ssm')
        github_secret = ssm_client.get_parameter(
            Name=ssm_github_secret_path,
            WithDecryption=True
        )['Parameter']['Value']
    except Exception as e:
        return {
            "statusCode": 400,
            "headers": {
                "Cache-Control": "max-age=3600",
                "Message": e.__str__()
            }
        }
    if 'x-hub-signature-256' not in event['headers']:
        return {
            "statusCode": 400,
            "headers": {
                "Cache-Control": "max-age=3600",
                "Message": "missing 'x-hub-signature-256'"
            }
        }

    event_signature = event['headers']['x-hub-signature-256'].split("=")[1]
    generated_signature = hmac.new(github_secret.encode(), base64.b64decode(event['body']), 'sha256')
    if hmac.compare_digest(event_signature, generated_signature.hexdigest()):
        ### Let do something here, like publish event to SNS Topic
        return {
            "statusCode": 200,
            "headers": {
                "Cache-Control": "max-age=3600",
                "Message": "signature matched"
            }
        }

    return {
        "statusCode": 200,
        "headers": {
            "Cache-Control": "max-age=3600"
        }
    }
