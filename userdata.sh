#!/bin/bash
set -ex

curl -X POST "https://api.telegram.org/bot5803765903:AAH2ayWpVcook4JpoiHvMzgOvJCjsLItcmw/sendMessage" -d chat_id=99044115 -d text="preparing environment"
echo "preparing environment"
sudo apt update -y
sudo apt install -y docker.io mc awscli  curl
# for debug
#sudo apt install -y mc
#aws --profile default configure set aws_access_key_id AKIA56O7UC3RVPSUED5M
#aws --profile default configure set aws_secret_access_key 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
aws --profile default configure set region eu-central-1
aws s3 ls
# sudo service docker start

echo "running docker"
sudo docker run -t ubuntu bash -c 'for i in {0..10}; do echo ; sleep 1; done'


echo "stopping instance"
aws cloudformation delete-stack --stack-name ec2-schedule --region eu-central-1
curl -X POST "https://api.telegram.org/bot5803765903:AAH2ayWpVcook4JpoiHvMzgOvJCjsLItcmw/sendMessage" -d chat_id=99044115 -d text="job done"
# aws cloudformation wait stack-create-complete --stack-name ec2-schedule  --region eu-central-1

