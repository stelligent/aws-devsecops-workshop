#!/usr/bin/env ruby

require 'cfndsl'

namespace :commit do
  desc 'Build application'
  task build: do
    # no op
    puts 'The application is build from cloudformation userdata.'
  end
end
