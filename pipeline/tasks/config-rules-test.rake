#!/usr/bin/env ruby
namespace :acceptance do
  desc 'Run aws config rules'
  task :config_rules_test do
    stage = 'prod'
    reg = ENV['AWS_REGION']
    cwd = '/opt/config-rule-status'
    output = 'config_results.txt'

    # rubocop:disable LineLength
    sh "echo '{}' | gulp verify --stage #{stage} --region #{reg} --cwd #{cwd} > #{output}"
    # rubocop:enable LineLength

    # Uncomment to fail based on config rule output
    # fail_result = /"result": "FAIL"/
    # Config rules don't bubble up an error so search the output
    # sh "cat #{output}"
    # raise 'A config rule failed' if File.open(output).grep(fail_result)
  end
end
