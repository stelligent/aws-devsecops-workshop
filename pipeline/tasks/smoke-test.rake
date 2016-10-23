#!/usr/bin/env ruby

namespace :deployment do
  desc 'Smoke test the production deployment'
  task :smoke_test do
    puts 'Smoke testing the deployment'
  end
end
