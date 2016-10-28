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

      penetration_test
    end

    def penetration_test
      run_penetration_test
      results
    end

    def results
      result_output = JSON.parse(File.read('results.json'))

      result_output.each do |issue|
        puts "#{issue['risk']}: #{issue['alert']}"
        puts "Description: #{issue['description']}"
        puts "Solution: #{issue['solution']}"
        puts '---'
      end
    end

    def run_penetration_test
      system '/var/lib/jenkins/pen-test-app.py',
             '--zap-host', 'localhost:80',
             '--target', "http://#{webserver_ip}"
      system 'behave features/penetration_test.feature'
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
