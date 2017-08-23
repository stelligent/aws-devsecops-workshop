#!/bin/bash

if [ -z ${TRUSTED_CIDR} ]; then
  echo -e "\n\nPlease export TRUSTED_CIRD. Example: '0.0.0.0/0'\n\n"
  exit 1
fi
if [ -z ${SSH_KEY_NAME} ]; then
  echo -e "\n\nPlease export SSH_KEY_NAME. Example: 'my-ec2-keypair'\n\n"
  exit 1
fi
if [ -z ${TOP_LEVEL_DOMAIN} ]; then
  echo -e "\n\nPlease export TOP_LEVEL_DOMAIN with trailing dot."
  echo -e "The Top Level Domain must be hosted in the account in which this stack is being launched."
  echo -e "Example: 'example.com.'\n\n"
  exit 1
fi


INSTANCE_TYPE="t2.small"
STACK_NAME="AWS-DEVSECOPS-WORKSHOP-JENKINS"

if [ $# -gt 0 ]; then
  case "$1" in
    update)
      echo -e "\n\nUpdating DevSecOps Workshop Stack:\n\n"
      aws cloudformation update-stack \
        --stack-name ${STACK_NAME} \
        --template-body file://./provisioning/cloudformation/templates/workshop-jenkins.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters \
          ParameterKey=InstanceType,ParameterValue=${INSTANCE_TYPE} \
          ParameterKey=TopLevelDomain,ParameterValue=${TOP_LEVEL_DOMAIN} \
          ParameterKey=JenkinsKeyName,ParameterValue=${SSH_KEY_NAME} \
          ParameterKey=TrustedCIDR,ParameterValue=${TRUSTED_CIDR}
      ;;
    delete)
      echo -e "\n\nDeleting DevSecOps Workshop Stack:\n\n"
      aws cloudformation delete-stack --profile ${PROFILE} --stack-name ${STACK_NAME}
      ;;
    rezs)
      echo -e "\n\nDevSecOps Stack Resources:\n\n"
      aws cloudformation describe-stack-resources --profile ${PROFILE} --stack-name ${STACK_NAME}
      ;;
    status)
      echo -e "\n\nDevSecOps Stack Status:\n\n"
      aws cloudformation describe-stacks --profile ${PROFILE} --stack-name ${STACK_NAME}
      ;;
    watch)
      watch "aws cloudformation describe-stack-events --profile ${PROFILE} --stack-name ${STACK_NAME}"
      ;;
    events)
      aws cloudformation describe-stack-events --profile ${PROFILE} --stack-name ${STACK_NAME} | nl
      ;;
    *) echo -e "\n\nValid commands are 'update', 'status', 'watch', 'events', 'rezs', or 'delete'\n\n"
      exit 1
      ;;
  esac
else
  echo -e "\n\nDeploying DevSecOps Workshop Stack:\n\n"
  aws cloudformation create-stack \
    --stack-name ${STACK_NAME} \
    --template-body file://./provisioning/cloudformation/templates/workshop-jenkins.json \
    --disable-rollback \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters \
      ParameterKey=InstanceType,ParameterValue=${INSTANCE_TYPE} \
      ParameterKey=TopLevelDomain,ParameterValue=${TOP_LEVEL_DOMAIN} \
      ParameterKey=JenkinsKeyName,ParameterValue=${SSH_KEY_NAME} \
      ParameterKey=TrustedCIDR,ParameterValue=${TRUSTED_CIDR}
fi
