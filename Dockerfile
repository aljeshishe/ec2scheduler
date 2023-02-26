# syntax = docker/dockerfile:experimental
FROM public.ecr.aws/lambda/python:3.8


WORKDIR ${LAMBDA_TASK_ROOT}

RUN pip3 install awscli && aws --profile default configure set region eu-central-1
RUN yum install make -y
#ADD install.sh ./
#RUN --mount=type=cache,mode=0777,target=/var/cache/yum ./install.sh
COPY . ./
CMD [ "handler.handler" ]

