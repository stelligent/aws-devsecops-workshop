#!/usr/bin/env ruby

$LOAD_PATH << './pipeline/lib'

require 'cucumber'
require 'eat'
require 'pipeline/state'
require 'rspec'
require 'socket'
require 'timeout'

Given(/^that the "([^"]*)" server has a public IP address$/) do |environment|
  @target_host = Pipeline::State.retrieve(environment, 'WEBSERVER_IP')
  expect(@target_host).to match(/.{4}/)
end

Given(/^that the server is responding to requests on port (\d+)$/) do |port|
  expect do
    Timeout.timeout(1) do
      begin
        begin
          socket = TCPSocket.new(@target_host, port)
          socket.close
          raise 'Port is open!'
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          raise 'Connection refused for port 80 on #{@target_host}.'
        end
      rescue Timeout::Error
        raise 'Timed out reaching port 80 on #{@target_host}.'
      end
    end
  end.to raise_error('Port is open!')
end

Then(/^the webpage index should display "([^"]*)"$/) do |page_content|
  expect(eat("http://#{@target_host}")).to include(page_content)
end
