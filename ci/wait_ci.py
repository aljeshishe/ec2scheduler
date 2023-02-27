import time

import boto3

expected_entity = "ec2scheduler-complete"


def run(timeout=60*10):
    print(f"Waiting for {expected_entity} bucket...")
    s3 = boto3.resource('s3')
    start = time.time()
    while time.time() - start < timeout:
        result = s3.buckets.all()
        for bucket in result:
            if bucket.name == expected_entity:
                print(f"Found {expected_entity}. Deleting")
                bucket.delete()
                exit(0)
    print(f"{expected_entity} not found")
    exit(1)


if __name__ == "__main__":
    run()

# sdb.list_domains() results example
# {
#     'DomainNames': [
#         'string',
#     ],
#     'NextToken': 'string'
# }
