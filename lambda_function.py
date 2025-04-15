import json
import logging

# Initialize logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Log the incoming event details
    logger.info("Event received: %s", json.dumps(event))

    # You can process the event further if needed
    for record in event['Records']:
        s3_event = record['s3']
        bucket_name = s3_event['bucket']['name']
        object_key = s3_event['object']['key']

        # Log S3 event details to CloudWatch Logs
        logger.info(f"Bucket: {bucket_name}, Object: {object_key}")

    return {
        'statusCode': 200,
        'body': json.dumps('Event processed successfully')
    }
