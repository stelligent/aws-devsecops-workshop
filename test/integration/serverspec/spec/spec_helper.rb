#!/usr/bin/env ruby

require 'serverspec'
require 'net/ssh'

set :backend, :ssh

set :host, ENV['TARGET_HOST']
set :ssh_options, Net::SSH::Config
  .for(ENV['TARGET_HOST'])
  .merge(user: 'ec2-user', keys: ENV['KEY'], paranoid: false)
