#!/usr/bin/env ruby

namespace :commit do
  desc 'Build application'
  task :build do
    # no op
    puts 'The application is build from cloudformation userdata.'
  end
end
