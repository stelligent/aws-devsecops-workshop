# Developing on AWS DevSecOps Workshop
A continuous security pipeline demo for the AWS DevSecOps Workshop.

## Prerequisites
Before you get started, there's a couple things you're going to need to prepare.

### AWS Account
We recommend using a new AWS account for the workshop environment. You can also use an existing account, but make sure the account has no existing resources created. Some of the security checks executed by this workshop may discover resources that are not configured to best practices and fail your pipeline.

#### IAM User
On your new account, create an IAM user with MFA enabled to use to provision your workshop environment.

### Development Environment

#### Ruby 2.2.5
Your development environment must have ruby 2.2.5 or better to install the dependencies of the scripts used to stand up the workshop environment. [RVM](https://rvm.io/) is a tool that can be used for switching between multiple versions.

#### AWS Credentials
[Install the aws-cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os) and use `aws configure` to set your AWS Access Keys into your development environment.

## Setup Jenkins
This repository contains some scripts to stand up a Jenkins in AWS pre-configured to execute this pipeline.

**Note** You must run the following scripts from an environment configured with AWS API Credentials or an instance with an IAM role attached with permission to access CloudFormation and EC2.

### Create Workshop Environment
This script uses cloudformation to provision a VPC and a Jenkins server.

```bash
$ bundle install
$ rake jenkins:create
```

You can include a parameter to specify your VPN CIDR block for a more secure NACL/Security Group configuration:

Limits inbound/outbound traffic to the VPC, Github and your CIDR block.
```bash
$ bundle install
$ rake jenkins:create['192.0.0.0/24','git-repo-url']
```

## Updating CloudFormation Templates

1. Update the  the templates
2. Upload to S3

Uploading to S3:
```bash
aws s3 cp \
  provisioning/cloudformation/templates/workshop-jenkins.json \
  s3://aws-devsecops-workshop/workshop-jenkins.json
```
