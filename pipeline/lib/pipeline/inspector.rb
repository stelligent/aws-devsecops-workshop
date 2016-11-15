#!/usr/bin/env ruby

require 'aws-sdk'
require 'fileutils'

module Pipeline
  # Class for handling inspector tests
  class Inspector
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION']
      @params[:region] ||= 'us-east-1'
      @cloudformation = Aws::CloudFormation::Client
                        .new(region: @params[:region])
      @inspector = Aws::Inspector::Client.new(region: @params[:region])

      setup_inspector
      run_inspector
      cleanup_inspector
    end

    def setup_inspector
      clone
      configure_iam
    end

    def configure_iam
      configure_inspector_role unless inspector_role_configured?
    end

    def inspector_role_configured?
      role = @inspector.describe_cross_account_access_role

      !role.role_arn.empty? && role.valid
    rescue NoMethodError
      false
    end

    def configure_inspector_role
      @inspector.register_cross_account_access_role(
        role_arn: inspector_role_arn
      )

      # It takes a moment for validation
      sleep 30
    end

    def inspector_role_arn
      stack = @cloudformation.describe_stacks(
        stack_name: ENV['STACK_NAME']
      ).stacks.first

      stack.outputs.each do |output|
        return output.output_value if output.output_key == 'InspectorRoleArn'
      end
    end

    def clone
      # Ensure a clean slate
      cleanup_inspector

      # Clone the repo
      system 'git', 'clone', 'https://github.com/stelligent/inspector-status'

      # No tags on this project yet :-(
      Dir.chdir('inspector-status') do
        system 'git', 'reset', '--hard',
               '08127dbb57b4f419c1eb77b19a588873949b0ebb'
      end
    end

    def run_inspector
      # This is required for inspector -- weird
      ENV['AWS_REGION'] ||= 'us-east-1'

      Dir.chdir('inspector-status') do
        system 'bundle', 'install'
        system './inspector.rb', '--target-tags', 'InspectorAuditable:true',
               '--aws-name-prefix', 'AWS-DEVSECOPS-WORKSHOP',
               '--failure-metrics', 'numeric_severity:9',
               '--rules-to-run', 'SEC,COM,RUN,CIS'
      end
    rescue RuntimeError => errors
      cleanup_inspector
      raise errors
    end

    def cleanup_inspector
      FileUtils.rm_rf('inspector-status')
    end
  end
end
