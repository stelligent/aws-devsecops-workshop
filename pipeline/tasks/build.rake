#!/usr/bin/env ruby

namespace :commit do
  desc 'Build application'
  task :build do
    # no op
    puts 'The application is build from cloudformation userdata.'
  end

  desc 'Install custom CFN_Nag rules'
  task :'cfn_nag:rules' do
    gem_path = ENV['GEM_HOME']
    igw_rules_path = 'lib/json_rules/igw_rules.rb'
    File.write(
      "#{gem_path}/gems/cfn-nag-0.0.19/#{igw_rules_path}",
      File.read("pipeline/lib/cfn_nag/#{igw_rules_path}")
    )
  end
end
