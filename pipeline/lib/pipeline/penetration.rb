#!/usr/bin/env ruby

# /pen-test-app.py --zap-host 192.168.1.5:8080 --target http://192.168.1.73:5000

require 'aws-sdk'
require 'pipeline/cfn_helper'

# Pipeline
module Pipeline
  # Class for handling inspector tests
  class Penetration < CloudFormationHelper
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION']
      @params[:region] ||= 'us-east-1'
      @cloudformation = Aws::CloudFormation::Client
                        .new(region: @params[:region])

      penetration_test
    end

    def penetration_test
      run_penetration_test
      results
    end

    def run_penetration_test
      system '/var/lib/jenkins/pen-test-app.py',
             '--zap-host', 'localhost:80',
             '--target', "http://#{webserver_ip}"
    end

    def webserver_ip
      stack = @cloudformation.describe_stacks(
        stack_name: 'AWS-DEVSECOPS-WORKSHOP-DEPLOY-ACCEPTANCE'
      ).stacks.first

      stack.outputs.each do |output|
        return output.output_value if output.output_key == 'EC2PrivateIP'
      end
    end
  end
end
