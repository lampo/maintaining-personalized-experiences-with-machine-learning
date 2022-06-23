#!/bin/bash

# exit when any command fails
set -e
source /app/.venv/bin/activate
cd /app/source/infrastructure

if [[ -z "${AWS_ACCOUNT_ID}" ]]; then
    echo "Must provide AWS_ACCOUNT_ID in environment" 1>&2
    exit 1
fi

CFN_SERVICE_ROLE="arn:aws:iam::${AWS_ACCOUNT_ID}:role/cfn-service-sagemaker-cdk-role"

DEPLOYMENT_ROLE=$(aws sts get-caller-identity --query 'Arn' --output text)

printf "\n> Starting deploy script\n"
printf "\n> Running deploy as %s\n" "${DEPLOYMENT_ROLE}"

printf "\n> Running CDK deploy as %s\n" "${CFN_SERVICE_ROLE}"
cdk synth
#cdk diff --role-arn "${CFN_SERVICE_ROLE}"
#cdk deploy --role-arn "${CFN_SERVICE_ROLE}"