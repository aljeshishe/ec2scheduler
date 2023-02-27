import boto3

bucket_name = "ec2scheduler-complete"
print(f"Creating {bucket_name=}")

s3 = boto3.resource('s3')
s3.create_bucket(Bucket=bucket_name, CreateBucketConfiguration={'LocationConstraint': 'eu-central-1'})
