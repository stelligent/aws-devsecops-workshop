pipelineJob('aws-devsecops-workshop') {
  displayName('AWS DevSecOps Workshop Pipeline')

  description('An example pipeline showcasing the deployment of an application with a security focused pipeline.')

  concurrentBuild(false)

  definition {
    cpsScm {
      scm {
        git {
          branch('master')
          remote {
            url('https://github.com/stelligent/aws-devsecops-workshop.git')
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
