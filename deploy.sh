#!/bin/bash -ex

AWS_PROFILE=default
AWS_REGION=us-east-1
INSTANCE_TYPE=t2.small
JENKINS_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-JENKINS
VPC_STACK_NAME=AWS-DEVSECOPS-WORKSHOP-VPC
JENKINS_STACK_TEMPLATE=./provisioning/cloudformation/templates/workshop-jenkins.yml
VPC_STACK_TEMPLATE=./provisioning/cloudformation/templates/workshop-vpc.yml
SUBNET_CIDR=10.10.21.0/24
VPC_CIDR=10.10.21.0/22
OWASP_ZAP_VERSION=2.5.0
IMAGE_ID=ami-97785bed  # latest amzn linux
SSH_KEY_NAME=devsecops
GITHUB_OWNER=stelligent
GITHUB_BRANCH=master

# allow outbound traffic
RUBYGEMS_CIDR=151.101.0.0/16
GITHUB_CIDR=192.30.252.0/22
AMAZON_CIDR_1=54.224.0.0/12
AMAZON_CIDR_2=52.192.0.0/11
UBUNTU_CIDR=0.0.0.0/0  # fixme

if [ "${TRUSTED_CIDR}" == "0.0.0.0/0" -o -z "${TRUSTED_CIDR}" ]; then
   echo 'Please export TRUSTED_CIDR and ensure it is not open to the world (0.0.0.0/0).'
   exit 1
fi

VPC_PARAMETERS="\
  TrustedCIDR=${TRUSTED_CIDR} \
  UbuntuCIDR=${UBUNTU_CIDR} \
  AmazonCIDR1=${AMAZON_CIDR_1} \
  AmazonCIDR2=${AMAZON_CIDR_2} \
  GithubCIDR=${GITHUB_CIDR} \
  RubygemsCIDR=${RUBYGEMS_CIDR} \
  SubnetCIDR=${SUBNET_CIDR} \
  VpcCIDR=${VPC_CIDR} \
"

JENKINS_PARAMETERS="\
  InstanceType=${INSTANCE_TYPE} \
  JenkinsKeyName=${SSH_KEY_NAME} \
  TrustedCIDR=${TRUSTED_CIDR} \
  ZapVersion=${OWASP_ZAP_VERSION} \
  ImageId=${IMAGE_ID} \
  GitHubOwner=${GITHUB_OWNER} \
  GitHubBranch=${GITHUB_BRANCH} \
"

echo -e "\n\nDeploying DevSecOps Workshop VPC Stack:\n\n"
aws cloudformation deploy \
  --profile ${AWS_PROFILE} \
  --region ${AWS_REGION} \
  --stack-name ${VPC_STACK_NAME} \
  --template-file ${VPC_STACK_TEMPLATE} \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides ${VPC_PARAMETERS}

echo -e "\n\nDeploying DevSecOps Workshop Jenkins Stack:\n\n"
aws cloudformation deploy \
  --profile ${AWS_PROFILE} \
  --region ${AWS_REGION} \
  --stack-name ${JENKINS_STACK_NAME} \
  --template-file ${JENKINS_STACK_TEMPLATE} \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides ${JENKINS_PARAMETERS}

echo -e "\n\nDeploying DevSecOps Workshop ConfigService Stacks:\n\n"
for CONFIG_TEMPLATE_PATH in $(ls provisioning/cloudformation/templates/configservice/); do
  CONFIG_TEMPLATE_NAME=$(echo $CONFIG_TEMPLATE_PATH | cut -f1 -d\. | sed 's|_|-|g')
  aws cloudformation deploy \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --stack-name AWS-DEVSECOPS-WORKSHOP-CONFIGSERVICE-${CONFIG_TEMPLATE_NAME} \
    --template-file ./provisioning/cloudformation/templates/configservice/${CONFIG_TEMPLATE_PATH} \
    --no-fail-on-empty-changeset
done
