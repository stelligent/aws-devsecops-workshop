#!/usr/bin/env ruby

require 'pipeline/deploy'
require 'pipeline/state'

namespace :acceptance do
  desc 'Create acceptance environment'
  task :create_environment do
    Pipeline::Deploy.new environment: 'acceptance'
  end
end
