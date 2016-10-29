#!/usr/bin/env ruby

namespace :deployment do
  desc 'Deploy the production environment'
  task :production do
    Pipeline::Deploy.new environment: 'production'
  end

  desc 'Smoke test the production deployment'
  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = '--tags @production features/webserver.feature'
  end
end
