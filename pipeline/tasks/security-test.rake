#!/usr/bin/env ruby

namespace :commit do
  desc 'Static security tests'
  task :security_test do
    puts 'Security / Static Analysis testing against infrastructure as code'
  end
end

namespace :acceptance do
  desc 'Integration security tests'
  task :security_test do
    puts 'Security / Integration testing against environment'
  end
end

namespace :capacity do
  desc 'Penetration security tests'
  task :security_test do
    puts 'Security / Penetration testing against application'
  end
end
