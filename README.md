# aws-devsecops-workshop
A continuous security pipeline demo for the AWS DevSecOps Workshop.

## Prerequisites
Before you get started, there are a few things you will to need to prepare.


### AWS Account
We recommend using a new AWS account for the workshop environment. You can also use an existing account, but make sure the account has no existing resources created. Some of the security checks executed by this workshop may discover resources that are not configured to best practices and fail your pipeline.


### AWS CLI
[Install the aws-cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os) and use `aws configure` to set your AWS Access Keys for your development environment (the account specified above).


## Jenkins Configuration
- Jenkins is bootstrapped via an Ansible Playbook executed in CFN cloud-init.
- Ansible Playbook expects latest Amazon Linux AMI.
- Jenkins auto-generated initial password is made permanent.
- Jenkins admin username/password are written to SSM ParameterStore.
- The following SSM Keys are populated:
```
/DevSecOps/jenkins_ip
/DevSecOps/jenkins_user
/DevSecOps/jenkins_password
```


## Pipeline Stages
- Commit
  1. cfn_nag
  2. rubocop
  3. unit tests

- Acceptance
  1. create environment
    - cloudformation
  2. infrastructure tests
  3. integration tests
    - serverspec
    - cucumber
  4. security environment tests
    - aws configservice
    - aws inspector

- Capacity
  1. security penetration tests
    - owasp zap
  2. capactity tests
    - apache benchmark

- Deployment
  1. production deploy
  2. smoke tests
    - cucumber


## Create Workshop Environment

- One-button launch of the workshop environment:
  `./deploy.sh`
- TRUSTED_CIDR is expected to be exported in the environment (example: "export TRUSTED_CIDR=100.20.30.45/32")
- Variables at the top of `deploy.sh` may need to be customized.
    - `IMAGE_ID` variable is currently set to the latest Amazon Linux AMI for the **us-east-1** region. If deploying this into another region you must replace this variable's value with the correct AMI ID for the other region.



## Egress Rules
TODO: Lockdown outgoing traffic
- prevent exfiltration with egress rules
- Github, RubyGems, and AWS API Endpoints only traffic allowed out
