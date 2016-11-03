# aws-devsecops-workshop
A continuous security pipeline demo for the AWS DevSecOps Workshop.

## Prerequisites
Before you get started, there's a couple things you're going to need to prepare.

### AWS Account
We recommend using a new AWS account for the workshop environment. You can also use an existing account, but make sure the account has no existing resources created. Some of the security checks executed by this workshop may discover resources that are not configured to best practices and fail your pipeline.

## Setup Jenkins
This repository contains some scripts to stand up a Jenkins in AWS pre-configured to execute this pipeline.

### Create Workshop Environment

One-button launch of the workshop environment:

[![Launch CFN stack](https://s3.amazonaws.com/stelligent-training-public/public/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#cstack=sn~AWS-DEVSECOPS-WORKSHOP-JENKINS|turl~https://s3.amazonaws.com/aws-devsecops-workshop/workshop-jenkins.json)

To launch from the AWS Console, use the following CloudFormation template:
[`provisioning/cloudformation/templates/workshop-jenkins.json`](https://s3.amazonaws.com/aws-devsecops-workshop/workshop-jenkins.json)

To launch from the CLI, see this example:

```
aws cloudformation create-stack \
--stack-name AWS-DEVSECOPS-WORKSHOP-JENKINS  \
--template-body https://s3.amazonaws.com/aws-devsecops-workshop/workshop-jenkins.json \
--region us-east-1 \
--disable-rollback \
--capabilities="CAPABILITY_NAMED_IAM" \
--parameters ParameterKey=InstanceType,ParameterValue=t2.micro \
  ParameterKey=WorldCIDR,ParameterValue=0.0.0.0/0
```

To launch from your terminal, see this example:

```bash
$ bundle install
$ rake jenkins:create
```

See `docs/development.md` for more details about the ruby/rake tasks.

### Jenkins Credentials
The initial admin user to jenkins is preconfigured, the credentials are below.

**It is _highly_ recommended that you change the password to your workshop jenkins after creation.**

#### Login
* User: `workshop`
* Password: `Fancy$Treasury!Effective!Throw^6`

#### Github
You'll need to create a [jenkins credential set](https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Plugin) to access private repositories in Jenkins.
