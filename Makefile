SHELL:=/usr/bin/env bash

# $(V).SILENT:
include .env
export

TMP_DIR = /tmp/ec2sheduler_oiun34filw
STATE_FILE = $(TMP_DIR)/state.yaml
STACK_NAME = ec2scheduler

IMAGE_NAME=ec2scheduler
IMAGE_VERSION=latest
LOCAL_IMAGE=${IMAGE_NAME}:${IMAGE_VERSION}

#userdata.sh: .env userdata_template.sh
# 	set -a && source .env && set +a && envsubst < userdata_template.sh > userdata.sh
%:	  # thanks to chakrit
	@:	# thanks to William Pursell


.PHONY: setup
setup:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
	aws ecr-public create-repository --repository-name ${IMAGE_NAME} --region us-east-1 || true

.PHONY: teardown
teardown:
	aws ecr-public delete-repository --repository-name ${IMAGE_NAME} --force --region us-east-1

.PHONY: build
build:
	docker build -t ${LOCAL_IMAGE} ec2scheduler

.PHONY: push
push:
	REPO_URI=$$(aws ecr-public describe-repositories --region us-east-1 --query 'repositories[?repositoryName==`${IMAGE_NAME}`].repositoryUri' --output text) && \
	REMOTE_IMAGE=$${REPO_URI}:${IMAGE_VERSION} && \
	echo Pushing ${LOCAL_IMAGE} to $${REMOTE_IMAGE}  && \
	docker tag ${LOCAL_IMAGE} $${REMOTE_IMAGE} && \
	docker push $${REMOTE_IMAGE}

.PHONY: docker
docker:
	docker run -it --entrypoint bash ${LOCAL_IMAGE}

.PHONY: deploy
deploy:
	serverless  deploy --force --verbose

.PHONY: remove
remove:
	serverless  remove

.PHONY: invoke
invoke:
	sls invoke --function handler

.PHONY: logs
logs:
	sls logs --function handler

.PHONY: waitlogs
waitlogs:
	sls logs --function handler -t

.PHONY: task
task:
	pip3 install boto3 && \
	    python ci/task.py

.PHONY: all
all: setup build deploy invoke

.PHONY: waitci
waitci:
	pip3 install boto3 && \
	    python ci/wait_ci.py

.PHONY: ci
ci: setup build deploy invoke waitci teardown remove

