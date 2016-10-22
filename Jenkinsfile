#!/usr/bin/env groovy

def rubyVersion = 'ruby-2.2.5'
def rvmGemset = 'devsecops'

node('master') {
  currentBuild.result = "SUCCESS"

  try {
      stage('Commit') {
        withRvm {
          checkout scm
          sh 'echo "Configure Workspace"'
          sh 'which bundle || gem install bundler'
          sh 'bundle install'
          sh 'echo "Static Analysis"'
        }
      }

      stage('Build/Test') {
        withRvm {
          sh 'echo "Build"'
          sh 'echo "Unit Tests"'
        }
      }

      stage('Acceptance') {
        withRvm {
          sh 'echo "Integration Tests"'
          sh 'echo "Infrastructure Tests"'
        }
      }

      stage('Security') {
        withRvm {
          sh 'echo "CFN Nag"'
          sh 'echo "Config Rules"'
          sh 'echo "OWASP Zap!"'
        }
      }

      stage('Deployment') {
        withRvm {
          sh 'echo "Deployment to UAT"'
          sh 'echo "Smoke Tests"'
        }
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
def usingRvm(Closure stage) {
    RVM_HOME='$HOME/.rvm'
    paths = [
        "$RVM_HOME/gems/$rubyVersion@$rvmGemset/bin",
        "$RVM_HOME/gems/$rubyVersion@global/bin",
        "$RVM_HOME/rubies/$rubyVersion/bin",
        "$RVM_HOME/bin",
        "${env.PATH}"
    ]
    env.PATH = paths.join(':')
    env.GEM_HOME = "$RVM_HOME/gems/$rubyVersion@$rvmGemset"
    env.GEM_PATH = "$RVM_HOME/gems/$rubyVersion@$rvmGemset:$RVM_HOME/gems/$rubyVersion@global"
    env.MY_RUBY_HOME = "$RVM_HOME/rubies/$rubyVersion"
    env.IRBRC = "$RVM_HOME/rubies/$rubyVersion/.irbrc"
    env.RUBY_VERSION = "$rubyVersion"
    stage()
}

// Helper function for rake
def rake(String command) {
  sh "bundle exec rake $command"
}
