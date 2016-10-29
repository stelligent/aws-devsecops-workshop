#!/usr/bin/env ruby

namespace :deployment do
  desc 'Smoke test the production deployment'
  Cucumber::Rake::Task.new(:smoke_test) do |t|
    t.cucumber_opts = '--tags @production features/webserver.feature'
  end
end
