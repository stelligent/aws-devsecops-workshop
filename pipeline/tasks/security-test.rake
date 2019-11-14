# frozen_string_literal: true

require 'cfn-nag'
require 'pipeline/inspector'
require 'pipeline/penetration'
require 'pipeline/configservice'

namespace :commit do
  desc 'Static security tests'
  task :security_test do
    puts "\n\nCFN-NAG Static security tests"
    cfn_template = 'provisioning/cloudformation/templates/workshop-jenkins.yml'
    failures = CfnNag.new.audit_aggregate_across_files_and_render_results(input_path: File.open(cfn_template))
    raise "CFN Nag found #{failures} issue(s)." unless failures.to_i.zero?
  end
end

namespace :acceptance do
  desc 'Integration security tests'
  task security_test: %i[acceptance:configservice acceptance:inspector]

  desc 'Config Rule tests'
  task :configservice do
    puts "\n\nConfigService Rule tests"
    Pipeline::ConfigService.new
  end

  desc 'Execute AWS Inspector tests'
  task :inspector do
    puts "\n\nExecute AWS Inspector tests"
    Pipeline::Inspector.new
  end
end

namespace :capacity do
  desc 'Penetration security tests'
  task :security_test do
    puts 'Penetration security tests'
    Pipeline::Penetration.new
  end
end
