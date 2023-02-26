SHELL:=/usr/bin/env bash

# $(V).SILENT:


#userdata.sh: .env userdata_template.sh
# 	set -a && source .env && set +a && envsubst < userdata_template.sh > userdata.sh
%:      # thanks to chakrit
	@:    # thanks to William Pursell

.PHONY: setup
setup:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

.PHONY: build
build:
	docker build -t serverless-ec2-schedule-dev:appimage .

.PHONY: docker
docker:
	docker run -it --entrypoint bash serverless-ec2-schedule-dev:appimage

.PHONY: deploy
deploy:
	serverless  deploy --force --verbose

.PHONY: invoke
invoke:
	sls invoke --function handler

.PHONY: logs
logs:
	sls logs --function handler

.PHONY: waitlogs
waitlogs:
	sls logs --function handler -t



.PHONY: all
all: setup build deploy invoke

.PHONY: stackstart
stackstart: userdata.sh
	aws cloudformation create-stack --stack-name ec2-schedule --template-body file://ec2_instance.yaml \
	    --parameters ParameterKey=UserDataFile,ParameterValue=$(shell base64 -i userdata.sh | tr -d '\n') \
	    --capabilities CAPABILITY_NAMED_IAM
	aws cloudformation wait stack-create-complete --stack-name ec2-schedule
	# rm userdata.sh

.PHONY: stackinfo
stackinfo:
	aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs'

.PHONY: stackstop
stackstop:
	aws cloudformation delete-stack --stack-name ec2-schedule
	aws cloudformation wait stack-delete-complete --stack-name ec2-schedule

.PHONY: logs_
logs_:
	$(eval INSTANCE_ID := $(shell aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text))
	@echo INSTANCE_ID=$(INSTANCE_ID)
	aws ec2 get-console-output --instance-id $(INSTANCE_ID)  --output text

.PHONY: ssh_key
ssh_key:
	INSTANCE_ID=$$(aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text) && \
	echo INSTANCE_ID=$${INSTANCE_ID} && \
	ssh-keygen -t rsa -f ssh_key -N '' <<<y

.PHONY: connect_ssh_key
connect_ssh_key: ssh_key
	INSTANCE_ID=$$(aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text) && \
	echo INSTANCE_ID=$${INSTANCE_ID} && \
	aws ec2-instance-connect send-ssh-public-key --instance-id $${INSTANCE_ID}  --instance-os-user ubuntu  --ssh-public-key file://ssh_key.pub

.PHONY: stacklogs
stacklogs: connect_ssh_key
	PUBLIC_IP=$$(aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs[?OutputKey==`PublicIP`].OutputValue' --output text) && \
	ssh -o "IdentitiesOnly=yes"  -o "StrictHostKeyChecking no" -i ssh_key ubuntu@$${PUBLIC_IP}  'tail -c +0 -f /var/log/cloud-init-output.log'

.PHONY: stackssh
stackssh: connect_ssh_key
	PUBLIC_IP=$$(aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs[?OutputKey==`PublicIP`].OutputValue' --output text) && \
	ssh -o "IdentitiesOnly=yes"  -o "StrictHostKeyChecking no" -i ssh_key ubuntu@$${PUBLIC_IP}

.PHONY: stackbrowser
stackbrowser:
	INSTANCE_ID=$$(aws cloudformation describe-stacks --stack-name ec2-schedule --query 'Stacks[*].Outputs[?OutputKey==`InstanceId`].OutputValue' --output text) && \
	echo INSTANCE_ID=$${INSTANCE_ID} && \
	open https://eu-central-1.console.aws.amazon.com/ec2-instance-connect/ssh\?connType\=standard\&instanceId\=$${INSTANCE_ID}\&osUser\=ubuntu\&region\=eu-central-1\&sshPort\=22\#

.PHONY: stackdocker
stackdocker:
	docker run \
    --log-driver=awslogs \
    --log-opt awslogs-create-group=true \
    --log-opt awslogs-region=eu-central-1 \
    --log-opt awslogs-group=myLogGroup \
    -it ubuntu bash -c 'for i in {0..10000}; do echo $i; sleep 1; done'

#     --log-opt awslogs-datetime-format='\[%b %d, %Y %H:%M:%S\]' \
