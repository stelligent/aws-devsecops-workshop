#!/usr/bin/env groovy

node('master') {
  try {
      stage('Commit') {
        withRvm {
          // Checkout SCM
          checkout scm

          // Configure Workspace
          sh 'which bundle || gem install bundler'
          sh 'bundle install'

          // Build
          rake 'commit:build'

          // Configure CFN_Nag
          rake 'commit:cfn_nag:rules'

          // Static Analysis
          rake 'commit:static_analysis'

          // Security / Static Analysis
          rake 'commit:security_test'

          // Unit Tests
          rake 'commit:unit_test'
        }
      }

      stage('Acceptance') {
        def region = env.AWS_REGION == null ? 'us-east-1' : env.AWS_REGION
        withRvm {
          // Create Acceptance Environment
          rake 'acceptance:create_environment'

          // Infrastructure Tests
          rake 'acceptance:infrastructure_test'

          // Integration Tests
          rake 'acceptance:integration_test'

          // Security / Integration Tests
          rake 'acceptance:security_test'

          // Security / Config Rules Tests
          rake 'acceptance:config_rules_test'
        }
      }

      stage('Capacity') {
        withRvm {
          // Security / Penetration Tests
          rake 'capacity:security_test'

          // Capacity Test
          rake 'capacity:capacity_test'
        }
      }

      stage('Deployment') {
        withRvm {
          // Deployment
          rake 'deployment:production'

          // Deployment Verification
          rake 'deployment:smoke_test'
        }
      }

  } catch(err) {
    handleException(err)
  }
}

// Configures RVM for the workspace
def withRvm(Closure stage) {
  rubyVersion = 'ruby-2.2.5'
  rvmGemset = 'devsecops'
  RVM_HOME = '$HOME/.rvm'

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

// Exception helper
def handleException(Exception err) {
  println(err.toString());
  println(err.getMessage());
  println(err.getStackTrace());

  /* Mail currently not configured
  mail  body: "project build error is here: ${env.BUILD_URL}" ,
        from: 'aws-devsecops-workshop@stelligent.com',
        replyTo: 'no-reply@stelligent.com',
        subject: 'AWS DevSecOps Workshop Pipeline Build Failed',
        to: 'robert.murphy@stelligent.com'
  */

  throw err
}
