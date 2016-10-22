#!groovy

node('master') {
  currentBuild.result = "SUCCESS"

  try {
    stage 'Commit'
      checkout scm
      sh 'echo "Configure Workspace"'
      sh 'echo "Static Analysis"'
      sh 'echo "Build"'

    stage 'Security'
      sh 'echo "CFN Nag"'
      sh 'echo "Config Rules"'
      sh 'echo "OWASP Zap!"'

    stage 'Acceptance'
      sh 'echo "Integration Tests"'

    stage 'Deployment'
      sh 'echo "Deployment to UAT"'
  }
}
