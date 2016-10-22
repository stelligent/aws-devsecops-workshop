#!groovy

node('master') {

  currentBuild.result = "SUCCESS"

  try {

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

  } catch(err) {

    mail  body: "project build error is here: ${env.BUILD_URL}" ,
          from: 'aws-devsecops-workshop@stelligent.com',
          replyTo: 'no-reply@stelligent.com',
          subject: 'AWS DevSecOps Workshop Pipeline Build Failed',
          to: 'robert.murphy@stelligent.com'

    throw err

  }

}
