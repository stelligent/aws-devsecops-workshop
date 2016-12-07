#!/usr/bin/env ruby

require 'serverspec'
require_relative '../spec_helper'

describe 'Server Setup' do
  # Verify the AWS Agent is running
  describe command('/opt/aws/awsagent/bin/awsagent status') do
    its(:exit_status) { should eq 0 }
  end

  # Verify the CloudFormation wait json file was created
  describe file('/tmp/cfn-success') do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/SUCCESS/) }
  end
end
