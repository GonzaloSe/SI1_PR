#!/bin/env python3

import boto3
import json
import logging
import traceback
import os

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

ENDPOINT_URL = f"http://{os.getenv('LOCALSTACK_HOSTNAME')}:{os.getenv('EDGE_PORT')}"

TABLE_NAME = 'si1p1'


def get_dynamodb_resource():
    return boto3.resource(
        "dynamodb",
        aws_access_key_id='test',
        aws_secret_access_key='test',
        region_name='us-east-1',
        endpoint_url=ENDPOINT_URL
    )


DYNAMODB_RESOURCE = get_dynamodb_resource()


def handler(event, context):
    LOGGER.info('Escribiendo en dynamo')
    print("Received event: " + json.dumps(event, indent=2))
    try:
        req = json.loads(event['body'])
        username = event['pathParameters']['username']
        table = DYNAMODB_RESOURCE.Table(TABLE_NAME)
        response = table.put_item(
            Item={
                'User': username,
                'EMail': req['email']
            }
        )
    except Exception:
        print("Error....")
        print(f"error trace {traceback.format_exc()}")
        LOGGER.info(f"error trace {traceback.format_exc()}")
        resp_body = {'msg': f"error trace {traceback.format_exc()}"}
    else:
        print("OK...")
        print(f"{username} placed into dynamo")
        LOGGER.info(f"{username} placed into dynamo")
        resp_body = {'msg': f"{username} placed into dynamo"}
    # API GW compliant response
    resp = {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {
            "content-type": "application/json"
        },
        "body": json.dumps(resp_body)
    }
    return resp
