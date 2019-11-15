# frozen_string_literal: true

require 'serverspec'
require_relative '../spec_helper'

describe 'Server Setup' do
  # Verify packages installed
  %w[perl-devel zlib-devel openssl-devel gcc make].each do |package_name|
    describe package(package_name) do
      it { should be_installed }
    end
  end

  # Verify the AWS Agent is running
  describe command('/opt/aws/awsagent/bin/awsagent status') do
    its(:exit_status) { should eq 0 }
  end
end
