#!/usr/bin/env ruby

require 'cfndsl'

namespace :commit do
  desc 'Build application'
  task build: [:'commit:build_app_cfn_template',
               :'commit:build_jenkins_cfn_template',
               :'commit:build_penetration_cfn_template']

  task :build_app_cfn_template do
    # Compile the template
    cfndsl_path = 'provisioning/cloudformation/deployment.rb'
    cfn_template = CfnDsl.eval_file_with_extras(cfndsl_path).to_json

    # Write template to workspace
    File.write("#{cfndsl_path.split('.').first}.template", cfn_template)
  end

  task :build_jenkins_cfn_template do
    # Compile the template
    cfndsl_path = 'provisioning/cloudformation/jenkins.rb'
    cfn_template = CfnDsl.eval_file_with_extras(cfndsl_path).to_json

    # Write template to workspace
    File.write("#{cfndsl_path.split('.').first}.template", cfn_template)
  end

  task :build_penetration_cfn_template do
    # Compile the template
    cfndsl_path = 'provisioning/cloudformation/penetration.rb'
    cfn_template = CfnDsl.eval_file_with_extras(cfndsl_path).to_json

    # Write template to workspace
    File.write("#{cfndsl_path.split('.').first}.template", cfn_template)
  end
end
