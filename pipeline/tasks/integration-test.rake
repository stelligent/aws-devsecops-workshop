# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'cucumber/rake/task'

namespace :acceptance do
  desc 'Integration test the acceptance environment'
  task integration_test: %i[acceptance:serverspec acceptance:cucumber]

  desc 'Integration tests for server configuration'
  RSpec::Core::RakeTask.new(:serverspec) do |t|
    t.pattern = 'test/integration/serverspec/spec/**/*_spec.rb'
  end

  desc 'Integration tests for web service'
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = [
      'features/webserver.feature',
      '--tags @acceptance',
      '--format pretty'
    ]
  end
end
