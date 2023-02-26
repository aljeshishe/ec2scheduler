#!/bin/bash

echo hello world
aws s3 ls
make stackstart
#aws cloudformation create-stack --stack-name ec2-schedule --template-body file://ec2_instance.yaml --parameters ParameterKey=UserDataFile,ParameterValue=$(base64  -b -i userdata.sh)
#aws cloudformation wait stack-create-complete --stack-name ec2-schedule
