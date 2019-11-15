# frozen_string_literal: true

require 'aws-sdk'
require 'json'
require 'pipeline/cfn_helper'
require 'pipeline/state'

# Pipeline
module Pipeline
  # Class for handling inspector tests
  class Capacity < CloudFormationHelper
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
      puts("\n\n=== Capacity Testing Reports ===\n\n")
      puts(File.read('capacity_result.txt'))
      system 'cucumber features/capacity_test.feature'
    end

    def run_capacity_test
      `ab -n 1000 -c 25 'http://#{webserver_ip}/' > capacity_result.txt`
    end

    def webserver_ip
      Pipeline::State.retrieve('acceptance', 'WEBSERVER_PRIVATE_IP')
    end
  end
end
