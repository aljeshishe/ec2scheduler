print("hello")
def run():
    import boto3

    # Create a SimpleDB client
    sdb = boto3.client('sdb')

    # Create a domain
    sdb.create_domain(DomainName='ec2scheduler')

    # Put some data into the domain
    sdb.put_attributes(DomainName='ec2scheduler', ItemName='result', Attributes=[
        {'Name': 'attribute1', 'Value': 'value1'},
        {'Name': 'attribute2', 'Value': 'value2'},
    ])

    # Query the data
    response = sdb.select(SelectExpression='select * from mydomain')
    items = response['Items']
    for item in items:
        print(item['Name'])
        for attribute in item['Attributes']:
            print(attribute['Name'], attribute['Value'])
