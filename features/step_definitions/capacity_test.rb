#!/usr/bin/env ruby

require 'rspec'

Given(/^we have a result set from Apache Benchmark$/) do
  expect(File.exist?('capacity_result.txt')).to be true
end

Then(/^there should be no failed requests$/) do
  results = /Failed\srequests\:\s+(\d+)/
    .match(File.read('capacity_result.txt'))

  expect(results[1]).not_to be_empty
  expect(results[1].to_i).to be <= 0
end
