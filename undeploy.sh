#!/bin/bash -ex

AWS_PROFILE=default
AWS_REGION=us-east-1

VPC_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-VPC
JENKINS_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-JENKINS
DEPLOY_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-DEPLOY
CONFIGSERVICE_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-CONFIGSERVICE

echo -e "\n\nUnDeploying any orphaned deployment stacks:\n\n"
aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${DEPLOY_STACK_NAME}-PRODUCTION || true
aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${DEPLOY_STACK_NAME}-ACCEPTANCE || true

echo -e "\n\nUnDeploying DevSecOps Workshop ConfigService Stacks:\n\n"
for CONFIG_TEMPLATE_PATH in $(ls provisioning/cloudformation/templates/configservice/); do
  CONFIG_TEMPLATE_NAME=$(echo $CONFIG_TEMPLATE_PATH | cut -f1 -d\. | sed 's|_|-|g')
  aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${CONFIGSERVICE_STACK_NAME}-${CONFIG_TEMPLATE_NAME} || true
done

echo -e "\n\nUnDeploying DevSecOps Workshop Jenkins Stack:\n\n"
aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${JENKINS_STACK_NAME} || true

echo -e "\n\nUnDeploying DevSecOps Workshop VPC Stack:\n\n"
aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${VPC_STACK_NAME} || true
