SHELL:=/usr/bin/env bash

# $(V).SILENT:

TMP_DIR = /tmp/ec2scheduler_oiun34filw
STATE_FILE = $(TMP_DIR)/state.yaml
STACK_NAME = ec2scheduler

.PHONY: stackstart
stackstart:
	echo TASK=$$TASK
	aws cloudformation create-stack --stack-name $(STACK_NAME) --template-body file://template.yaml \
		--parameters ParameterKey=UserDataFile,ParameterValue=$(shell envsubst < userdata.sh | base64 | tr -d '\n') \
		--capabilities CAPABILITY_NAMED_IAM
	aws cloudformation wait stack-create-complete --stack-name $(STACK_NAME)
	# rm userdata.sh

.PHONY: stackinfo
stackinfo:
	aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query 'Stacks[*].Outputs'

.PHONY: stackstop
stackstop:
	aws cloudformation delete-stack --stack-name $(STACK_NAME)
	aws cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)

.PHONY: state
state:
	echo "Creating state file: $(STATE_FILE)"
	aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query 'Stacks[?StackName==`$(STACK_NAME)`] | [0]' --output yaml > $(STATE_FILE)


$(TMP_DIR):
	echo "Creating tmp dir: $(TMP_DIR)"
	mkdir -p $(TMP_DIR)

.PHONY: ssh_key
ssh_key: $(TMP_DIR) state
	INSTANCE_ID=$$(yq '.Outputs[] | select(.OutputKey == "InstanceId").OutputValue' < $(STATE_FILE)) && \
	echo INSTANCE_ID=$${INSTANCE_ID} && \
	ssh-keygen -t rsa -f $(TMP_DIR)/ssh_key -N '' <<<y

.PHONY: connect_ssh_key
connect_ssh_key: ssh_key state
	INSTANCE_ID=$$(yq '.Outputs[] | select(.OutputKey == "InstanceId").OutputValue' < $(STATE_FILE)) && \
	echo INSTANCE_ID=$${INSTANCE_ID} && \
	aws ec2-instance-connect send-ssh-public-key --instance-id $${INSTANCE_ID}  --instance-os-user ubuntu  --ssh-public-key file://$(TMP_DIR)/ssh_key.pub

.PHONY: stacklogs
stacklogs: state
	INSTANCE_ID=$$(yq '.Outputs[] | select(.OutputKey == "InstanceId").OutputValue' < $(STATE_FILE)) && \
	echo INSTANCE_ID=$${INSTANCE_ID} && \
	aws ec2 get-console-output --instance-id $${INSTANCE_ID}  --output text

.PHONY: stackwaitlogs
stackwaitlogs: connect_ssh_key state
	PUBLIC_IP=$$(yq '.Outputs[] | select(.OutputKey == "PublicIP").OutputValue' < $(STATE_FILE)) && \
	ssh -o "IdentitiesOnly=yes"  -o "StrictHostKeyChecking no" -i $(TMP_DIR)/ssh_key ubuntu@$${PUBLIC_IP}  'tail -c +0 -f /var/log/cloud-init-output.log'

.PHONY: stackssh
stackssh: connect_ssh_key state
	PUBLIC_IP=$$(yq '.Outputs[] | select(.OutputKey == "PublicIP").OutputValue' < $(STATE_FILE)) && \
	ssh -o "IdentitiesOnly=yes"  -o "StrictHostKeyChecking no" -i file://$(TMP_DIR)/ssh_key ubuntu@$${PUBLIC_IP}

.PHONY: stackbrowser
stackbrowser: state
	INSTANCE_ID=$$(yq '.Outputs[] | select(.OutputKey == "InstanceId").OutputValue' < $(STATE_FILE)) && \
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

#	 --log-opt awslogs-datetime-format='\[%b %d, %Y %H:%M:%S\]' \
