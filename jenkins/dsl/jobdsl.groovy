pipelineJob('aws-devsecops-workshop') {
    displayName('AWS DevSecOps Workshop Pipeline')

    description('An example pipeline showcasing the deployment of an application with a security focused pipeline.')

    definition {
        cpsScm {
            scm {
                git {
                    branch('master')
                    remote {
                        github('stelligent/aws-devsecops-workshop')
                    }
                }
            }

            scriptPath('Jenkinsfile')
        }
    }
}
