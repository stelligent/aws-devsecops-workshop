# frozen_string_literal: true

require 'cfn-nag'
require 'pipeline/inspector'
require 'pipeline/penetration'
require 'pipeline/configservice'

namespace :commit do
  desc 'Static security tests'
  task :security_test do
    puts "\n\nCFN-NAG Static security tests"
    cfn_templates_path = "#{Dir.pwd}/provisioning/cloudformation/templates/"
    cfn_nag_rules_dir = "#{Dir.pwd}/pipeline/lib/cfn_nag/lib/cfn-nag/custom_rules/"
    puts cfn_templates_path
    system("cfn_nag_scan --rule-directory #{cfn_nag_rules_dir} --input-path #{cfn_templates_path}")
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
