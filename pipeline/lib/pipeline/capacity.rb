#!/usr/bin/env ruby

require 'aws-sdk'
require 'json'
require 'pipeline/cfn_helper'

# Pipeline
module Pipeline
  # Class for handling inspector tests
  class Penetration < CloudFormationHelper
    def initialize
      @cloudformation = Aws::CloudFormation::Client
                        .new(region: aws_region)

      capacity_test
    end

    def capacity_test
      run_capacity_test
      results
    end

    def results
      puts File.read('capacity_result.txt')
      system 'cucumber features/capacity_test.feature'
    end

    def run_capacity_test
      `ab -n 1000 -c 25 'http://#{webserver_ip}/' > capacity_result.txt`
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
