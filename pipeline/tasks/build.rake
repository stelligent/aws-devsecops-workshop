#!/usr/bin/env ruby

require 'cfndsl'

namespace :commit do
  desc 'Build application'
  task build: [:'commit:build_cfn_template']

  task :build_cfn_template do
    # Compile the template
    cfndsl_path = 'provisioning/cloudformation/deployment.rb'
    cfn_template = CfnDsl.eval_file_with_extras(cfndsl_path).to_json

    # Write template to workspace
    File.write("#{cfndsl_path.split('.').first}.template", cfn_template)
  end
end
