#!/usr/bin/env ruby

require 'cfn-nag'
require 'pipeline/inspector'
require 'pipeline/penetration'

namespace :commit do
  desc 'Static security tests'
  task :security_test do
    cfn_template = 'provisioning/cloudformation/templates/workshop-jenkins.json'
    failures = CfnNag.new.audit_aggregate_across_files_and_render_results(input_path: File.open(cfn_template))
    raise "CFN Nag found #{failures} issue(s)." unless failures.to_i.zero?
  end
end

namespace :acceptance do
  desc 'Integration security tests'
  task security_test: [:'acceptance:inspector']

  desc 'Execute AWS Inspector tests'
  task :inspector do
    Pipeline::Inspector.new
  end
end

namespace :capacity do
  desc 'Penetration security tests'
  task :security_test do
    Pipeline::Penetration.new
  end
end
