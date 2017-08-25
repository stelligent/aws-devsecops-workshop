require 'pipeline/capacity'

namespace :capacity do
  desc 'Capacity test acceptance environment'
  task :capacity_test do
    Pipeline::Capacity.new
  end
end
