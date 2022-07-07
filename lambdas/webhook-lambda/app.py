import os
import boto3
import json
import logging
import time
import hmac
import base64

ssm_github_secret_path = os.getenv("SSM_GITHUB_SECRET_PATH")
topic_arn = os.getenv("TOPIC_ARN")

sns_client = boto3.client('sns')


def handler(event, context):
    try:
        ssm_client = boto3.client('ssm')
        github_secret = ssm_client.get_parameter(
            Name=ssm_github_secret_path,
            WithDecryption=True
        )['Parameter']['Value']
    except Exception as e:
        print(e.__str__())
        return {
            "statusCode": 400,
            "headers": {
                "Cache-Control": "max-age=3600",
                "Message": "Internal Server Error, please check logs"
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
    if event['isBase64Encoded'] == 'True':
        signature_body = base64.b64decode(event['body'])
    else:
        signature_body = event['body']
    generated_signature = hmac.new(github_secret.encode('utf-8'), signature_body.encode('utf-8'), 'sha256')
    if hmac.compare_digest(event_signature, generated_signature.hexdigest()):
        ### Let do something here, like publish event to SNS Topic
        try:
            publish = sns_client.publish(TargetArn=topic_arn,
                                         Message=json.dumps({"default": signature_body}),
                                         MessageAttributes={"github_event": {"DataType": "String",
                                                                             "StringValue": event['headers']['x-github-event']}},
                                        MessageStructure = 'json')
        except Exception as e:
            print(e.__str__())
            return {
                "statusCode": 400,
                "headers": {
                    "Cache-Control": "max-age=3600",
                    "Message": "Can NOT publish message to SNS"
                }
            }

        return {
            "statusCode": publish['ResponseMetadata']['HTTPStatusCode'],
            "headers": {
                "Cache-Control": "max-age=3600"
            }
        }

    return {
        "statusCode": '500',
        "headers": {
            "Cache-Control": "max-age=3600",
            "Message": "Signature does not match"
        }
    }
