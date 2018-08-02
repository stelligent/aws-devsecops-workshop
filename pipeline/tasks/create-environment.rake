require 'pipeline/deploy'
require 'pipeline/state'

namespace :acceptance do
  desc 'Create acceptance environment'
  task :create_environment do
    puts 'Create acceptance environment'
    Pipeline::Deploy.new environment: 'acceptance'
  end
end
