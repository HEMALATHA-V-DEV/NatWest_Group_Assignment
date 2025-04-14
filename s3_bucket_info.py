import boto3

def list_buckets():
    s3 = boto3.client('s3')
    response = s3.list_buckets()
    print("S3 Buckets:")
    for bucket in response['Buckets']:
        print(f" - {bucket['Name']}")

def count_objects(bucket_name):
    s3 = boto3.client('s3')
    paginator = s3.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket_name)

    total_objects = 0
    for page in page_iterator:
        if 'Contents' in page:
            total_objects += len(page['Contents'])

    print(f"Total number of objects in bucket '{bucket_name}': {total_objects}")

if __name__ == "__main__":
    list_buckets()
    bucket_name = input("Enter the bucket name to count objects: ")
    count_objects(bucket_name)
