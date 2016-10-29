#!/usr/bin/env ruby

namespace :deployment do
  desc 'Deploy the production environment'
  task :production do
    Pipeline::Deploy.new environment: 'production'
  end
end
