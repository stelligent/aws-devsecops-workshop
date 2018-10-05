#!/bin/bash -ex

AWS_PROFILE=default
AWS_REGION=us-east-1

VPC_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-VPC
JENKINS_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-JENKINS

echo -e "\n\nUnDeploying DevSecOps Workshop VPC Stack:\n\n"
aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${VPC_STACK_NAME} 

echo -e "\n\nUnDeploying DevSecOps Workshop Jenkins Stack:\n\n"
aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name ${JENKINS_STACK_NAME}

echo -e "\n\nUnDeploying DevSecOps Workshop ConfigService Stacks:\n\n"
for CONFIG_TEMPLATE_PATH in $(ls provisioning/cloudformation/templates/configservice/); do
  CONFIG_TEMPLATE_NAME=$(echo $CONFIG_TEMPLATE_PATH | cut -f1 -d\. | sed 's|_|-|g')
  aws cloudformation delete-stack \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name AWS-DEVSECOPS-WORKSHOP-CONFIGSERVICE-${CONFIG_TEMPLATE_NAME}
done
