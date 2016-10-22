pipelineJob('aws-devsecops-workshop') {
    scm {
        github('stelligent/aws-devsecops-workshop', 'master')
    }
    triggers {
        githubPush()
    }
    definition {
        cps {
            script('Jenkinsfile')
            sandbox()
        }
    }
}
