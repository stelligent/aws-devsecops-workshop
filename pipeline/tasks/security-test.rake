#!/usr/bin/env ruby

require 'cfn_nag'

namespace :commit do
  desc 'Static security tests'
  task :security_test do
    template_path = 'provisioning/cloudformation/deployment.template'
    failures = CfnNag.new.audit(input_json_path: File.open(template_path),
                                output_format: 'txt')
    raise "CFN Nag found #{failures.to_i} issue(s)." if failures > 0
  end
end

namespace :acceptance do
  desc 'Integration security tests'
  task :security_test do
    puts 'Security / Integration testing against environment'
  end
end

namespace :capacity do
  desc 'Penetration security tests'
  task :security_test do
    puts 'Security / Penetration testing against application'
  end
end
