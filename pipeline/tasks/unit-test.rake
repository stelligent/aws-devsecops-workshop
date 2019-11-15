# frozen_string_literal: true

namespace :commit do
  desc 'CFN_NAG unit tests for custom  rules'
  task cfn_nag_unit_tests: [:unit_test_cfn_nag_custom_rules]
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:unit_test_cfn_nag_custom_rules) do |t|
    t.pattern = 'test/unit/spec/**/*_spec.rb'
  end
rescue LoadError
  puts "Unable to load rspec/core/rake_task\n"
end
