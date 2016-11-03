#!/usr/bin/env ruby

require 'cfn_nag'
require 'pipeline/inspector'
require 'pipeline/penetration'

namespace :commit do
  desc 'Static security tests'
  task security_test: [:'commit:cfn_nag:app',
                       :'commit:cfn_nag:jenkins']

  desc 'Execute CFN NAG tests against application'
  task :'cfn_nag:app' do
    template_path = 'provisioning/cloudformation/deployment.template'
    failures = CfnNag.new.audit(input_json_path: File.open(template_path),
                                output_format: 'txt')
    raise "CFN Nag found #{failures.to_i} issue(s)." if failures > 0
  end

  desc 'Execute CFN NAG tests against jenkins'
  task :'cfn_nag:jenkins' do
    template_path = 'provisioning/cloudformation/jenkins.template'
    failures = CfnNag.new.audit(input_json_path: File.open(template_path),
                                output_format: 'txt')
    raise "CFN Nag found #{failures.to_i} issue(s)." if failures > 0
  end
end

namespace :acceptance do
  desc 'Integration security tests'
  task security_test: [:'acceptance:inspector', :'acceptance:config_rules']

  desc 'Execute AWS Inspector tests'
  task :inspector do
    Pipeline::Inspector.new
  end

  desc 'Execute Config Rules Status tests'
  task :config_rules do
    region = ENV['AWS_REGION']
    region ||= 'us-east-1'
    Dir.chdir('/opt/config-rule-status') do
      system 'gulp', 'verify', '--stage',
             'prod', '--region', region
    end
  end
end

namespace :capacity do
  desc 'Penetration security tests'
  task :security_test do
    Pipeline::Penetration.new
  end
end
