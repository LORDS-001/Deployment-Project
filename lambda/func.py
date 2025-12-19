import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-counter')

def lambda_handler(event, context):
    response = table.update_item(
        Key={'id': 'counter'},
        UpdateExpression='ADD #c :inc',
        ExpressionAttributeNames={'#c': 'count'},
        ExpressionAttributeValues={':inc': 1},
        ReturnValues="UPDATED_NEW"
    )
    
    count = response['Attributes']['count']

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*', # Allows your website to call it
            'Content-Type': 'application/json'
        },
        'body': json.dumps({'count': int(count)})
    }