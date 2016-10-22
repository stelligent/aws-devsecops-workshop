#!/usr/bin/env groovy

node('master') {
  currentBuild.result = "SUCCESS"

  try {
    usingRvm {
      stage 'Commit'
        checkout scm
        sh 'echo "Configure Workspace"'
        sh 'echo "Static Analysis"'

      stage 'Build/Test'
        sh 'echo "Build"'
        sh 'echo "Unit Tests"'

      stage 'Acceptance'
        sh 'echo "Integration Tests"'
        sh 'echo "Infrastructure Tests"'

      stage 'Security'
        sh 'echo "CFN Nag"'
        sh 'echo "Config Rules"'
        sh 'echo "OWASP Zap!"'

      stage 'Deployment'
        sh 'echo "Deployment to UAT"'
        sh 'echo "Smoke Tests"'
    }
  } catch(err) {
    mail  body: "project build error is here: ${env.BUILD_URL}" ,
          from: 'aws-devsecops-workshop@stelligent.com',
          replyTo: 'no-reply@stelligent.com',
          subject: 'AWS DevSecOps Workshop Pipeline Build Failed',
          to: 'robert.murphy@stelligent.com'

    throw err
  }
}

// Configures RVM for the workspace
def usingRvm(Closure pipeline) {
  sh '. ~/.rvm/scripts/rvm'
  sh 'rvm use --install --create 2.2.5@devsecops'
  sh 'export > rvm.env'
  sh 'which bundle || gem install bundler'
  sh 'bundle install'
  pipeline()
}
