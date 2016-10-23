#!/usr/bin/env ruby

require 'rspec/core/rake_task'

namespace :acceptance do
  desc 'Integration test the acceptance environment'
  RSpec::Core::RakeTask.new(:integration_test) do |t|
    t.pattern = 'test/integration/serverspec/spec/**/*_spec.rb'
  end
end
