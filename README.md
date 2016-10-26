# aws-devsecops-workshop
A continuous security pipeline demo for the AWS DevSecOps Workshop.

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
$ rake jenkins:create['192.0.0.0/24']
```

### Teardown the Workshop Environment
```bash
$ rake jenkins:teardown
```

### Jenkins Credentials
The initial admin user to jenkins is preconfigured, the credentials are below.

**Please change the credentials as soon as you create the jenkins!**

#### Login
* User: `workshop`
* Password: `Fancy$Treasury!Effective!Throw^6`

#### Github
You'll need to create a jenkins credential set to access private repositories in Jenkins.
