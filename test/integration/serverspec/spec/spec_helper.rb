#!/usr/bin/env ruby

$LOAD_PATH << './pipeline/lib'

require 'serverspec'
require 'net/ssh'
require 'pipeline/state'

target_host = Pipeline::State.retrieve('acceptance', 'WEBSERVER_PRIVATE_IP')
keypair_path = Pipeline::State.retrieve('acceptance', 'KEYPAIR_PATH')

set :backend, :ssh

set :host, target_host
set :ssh_options, Net::SSH::Config
  .for(target_host)
  .merge(user: 'ec2-user', keys: keypair_path, paranoid: false)
