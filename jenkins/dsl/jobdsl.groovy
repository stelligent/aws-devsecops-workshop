pipelineJob('aws-devsecops-workshop') {
  displayName('AWS DevSecOps Workshop Pipeline')

  description('An example pipeline showcasing the deployment of an application with a security focused pipeline.')

  definition {
    cpsScm {
      scm {
        git {
          branch('master')
          remote {
            credentials('jenkins')
            url('git@github.com:stelligent/aws-devsecops-workshop.git')
          }
        }
      }

      scriptPath('Jenkinsfile')
    }
  }

  triggers {
    scm('* * * * *') {
      ignorePostCommitHooks(true)
    }
  }
}
