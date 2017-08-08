#!/bin/bash

PROFILE="stell"
STACK_NAME="AWS-DEVSECOPS-WORKSHOP-JENKINS"
TRUSTED_CIDR="0.0.0.0/0"


if [ $# -gt 0 ]; then
  case "$1" in
    update)
      echo -e "\n\nUpdating DevSecOps Workshop Stack:\n\n"
      aws cloudformation update-stack \
        --profile ${PROFILE} \
        --stack-name ${STACK_NAME} \
        --template-body file://./provisioning/cloudformation/templates/workshop-jenkins.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=InstanceType,ParameterValue=t2.small \
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
    --profile ${PROFILE} \
    --stack-name ${STACK_NAME} \
    --template-body file://./provisioning/cloudformation/templates/workshop-jenkins.json \
    --disable-rollback \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey=InstanceType,ParameterValue=t2.small \
      ParameterKey=TrustedCIDR,ParameterValue=${TRUSTED_CIDR}
fi
