# aws-devsecops-workshop
A continuous security pipeline demo for the AWS DevSecOps Workshop.

## Jenkins

### Prerequisites
* Jenkins 2.19+
* Jenkins Plugins:
* * [RVM](https://wiki.jenkins-ci.org/display/JENKINS/RVM+Plugin)
* * [Git](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin)
* * [Pipeline](https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin)

### Setting up your pipeline

#### Option 1: Pipeline Job
Create a pipeline job in jenkins to use this repository's Jenkinsfile to build the pipeline. You'll need to configure the RVM environment to use the gemset `2.2.5@devsecops`.

#### Option 2: Job DSL
If you have the [Job DSL](https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin) plugin installed, you can execute `jenkins/dsl/jobdsl.groovy` to create your pipeline.
