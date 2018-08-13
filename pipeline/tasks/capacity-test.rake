require 'pipeline/capacity'

namespace :capacity do
  desc 'Capacity test acceptance environment'
  task :capacity_test do
    puts 'Capacity test acceptance environment'
    Pipeline::Capacity.new
  end
end
