import os

import boto3


def handler(event, context):
    print("start")
    # create_stack()
    os.system("./handler.sh")
    print("end")


def create_stack():
    # Create an AWS CloudFormation resource
    cloudformation = boto3.resource('cloudformation')

    # Specify the CloudFormation stack name and template file location
    stack_name = 'ec2-schedule'
    template_file = 'ec2_instance.yaml'

    # Create a stack using the specified template
    with open(template_file) as f:
        template_body = f.read()

    stack = cloudformation.create_stack(
        StackName=stack_name,
        TemplateBody=template_body,
        Capabilities=['CAPABILITY_NAMED_IAM'],
        Parameters=[{
            'ParameterKey': 'UserDataFile',
            'ParameterValue': 'userdata.sh'
        }]

    )
    # Wait for the stack to be created
    cloudformation.get_waiter('stack_create_complete').wait(StackName=stack_name)

    # Print the stack ID and status
    stack_id = stack['StackId']
    stack_status = cloudformation.describe_stacks(StackName=stack_name)['Stacks'][0]['StackStatus']
    print(f'Stack ID: {stack_id}')
    print(f'Stack Status: {stack_status}')
    #
    # # Wait for the stack creation to complete
    # stack.wait_until_exists()
    #
    # # Check the stack status after completion
    # stack_status = stack.stack_status
    # if stack_status == 'CREATE_COMPLETE':
    #     print('Stack deployment complete')
    # else:
    #     print('Stack deployment failed with status:', stack_status)


if __name__ == "__main__":
    handler(None, None)