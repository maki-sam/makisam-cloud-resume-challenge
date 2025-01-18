import json
import boto3

dyndb = boto3.resource('dynamodb')
table = dyndb.Table('makisam_crc_table')

def lambda_handler(event, context):
    response = table.get_item(
        Key={'ID': '0'}
    )
    view_count = int(response['Item']['website-viewer'])
    view_count += 1

    table.put_item(
        Item={
            'ID': '0',
            'website-viewer': view_count
        }
    )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',  # Allow all origins
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
        },
        'body': json.dumps({'views': view_count})
    }