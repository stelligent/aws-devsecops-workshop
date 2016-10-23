#!/usr/bin/env ruby

require 'cucumber'
require 'eat'
require 'rspec'
require 'socket'
require 'timeout'

Given(/^that a server has a public IP address$/) do
  expect(ENV['TARGET_HOST']).to match(/.{4}/)
end

Given(/^that the server is responding to requests on port (\d+)$/) do |port|
  server_ip = ENV['TARGET_HOST']
  expect do
    Timeout.timeout(1) do
      begin
        begin
          socket = TCPSocket.new(server_ip, port)
          socket.close
          raise 'Port is open!'
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          raise 'Connection refused for port 80 on #{server_ip}.'
        end
      rescue Timeout::Error
        raise 'Timed out reaching port 80 on #{server_ip}.'
      end
    end
  end.to raise_error('Port is open!')
end

Then(/^the webpage index should display "([^"]*)"$/) do |page_content|
  server_ip = ENV['TARGET_HOST']

  expect(eat("http://#{server_ip}")).to include(page_content)
end
