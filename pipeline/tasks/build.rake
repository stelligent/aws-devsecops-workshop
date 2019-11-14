# frozen_string_literal: true

namespace :commit do
  desc 'Build application'
  task :build do
    # no op
    puts 'The application is build from cloudformation userdata.'
  end

  desc 'Install custom CFN_Nag rules'
  task :'cfn_nag:rules' do
    puts 'Install custom CFN_Nag rules'
    cfn_nag_path = File.read('cfn-nag.path').strip
    igw_rules_path = 'lib/cfn-nag/custom_rules/igw_rules.rb'
    File.write(
      "#{cfn_nag_path}/#{igw_rules_path}",
      File.read("pipeline/lib/cfn_nag/#{igw_rules_path}")
    )
  end
end
