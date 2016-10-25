# aws-devsecops-workshop
A continuous security pipeline demo for the AWS DevSecOps Workshop.

## Setup Jenkins
This repository contains some scripts to stand up a Jenkins in AWS pre-configured to execute this pipeline.

**Note** You must run the following scripts from an environment configured with AWS API Credentials or an instance with an IAM role attached with permission to access CloudFormation and EC2.

### Create the Jenkins
```bash
$ bundle install
$ rake jenkins:create['YOUR-VPC-ID','YOUR-SUBNET-ID','YOUR-CIDR-BLOCK']
# rake jenkins:create['vpc-aad5159f','subnet-e82cd2b5','68.0.0.0/8']
```

*Only include a CIDR block if you're running behind a Proxy, TIC or NAT Gateway.*

### Teardown the Jenkins
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
