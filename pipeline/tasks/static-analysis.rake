namespace :commit do
  desc 'Static analysis tests'
  task static_analysis: [:rubocop]
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  print "Unable to load rubocop/rake_task, rubocop tests missing\n"
end
