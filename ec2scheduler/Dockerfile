# syntax = docker/dockerfile:experimental
FROM public.ecr.aws/lambda/python:3.8
WORKDIR ${LAMBDA_TASK_ROOT}
RUN pip3 install awscli && \
    aws --profile default configure set region eu-central-1 && \
    yum install make gettext -y
COPY . ./
CMD [ "handler.handler" ]

