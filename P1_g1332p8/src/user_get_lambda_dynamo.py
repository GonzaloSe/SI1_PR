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
    try: # Intenta leer el usuario de la tabla con la función get_item dada la key username
        username = event['pathParameters']['username']
        table = DYNAMODB_RESOURCE.Table(TABLE_NAME)
        response = table.get_item(
            Key={
                'User': username
            }
        )
        item = response.get('Item', {})
    except Exception: # Si se produce una excepción, devuelve un error y pone el body a None
        print("Error....")
        print(f"error trace {traceback.format_exc()}")
        LOGGER.info(f"error trace {traceback.format_exc()}")
        resp_body = None
    else: # Si no se produce una excepción, devuelve un OK y pone el body a item
        print("OK...")
        print(f"{username} found in dynamo")
        LOGGER.info(f"{username} found in dynamo")
        resp_body = item
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
