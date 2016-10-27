#!/usr/bin/env ruby

require 'aws-sdk'
require 'fileutils'

module Pipeline
  # Class for handling inspector tests
  class Inspector
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION'] unless ENV['AWS_REGION'].nil?
      @params[:region] = 'us-east-1' if @params[:region].nil?
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
    end

    def configure_inspector_role
      @inspector.register_cross_account_access_role(
        role_arn: inspector_role_arn
      )
    end

    def inspector_role_arn
      stack = @cloudformation.describe_stacks(stack_name: stack_name)
                             .stacks.first

      stack.outputs.each do |output|
        return output.output_value if output.output_key == 'InspectorRoleArn'
      end
    end

    def clone
      # Clone the repo
      system 'git', 'clone', 'https://github.com/stelligent/inspector-status'

      # No tags on this project yet :-(
      Dir.chdir('inspector-status') do
        system 'git', 'reset', '--hard',
               '07985930275be843df6f84b2417af7a2aaa5cc76'
      end
    end

    def run_inspector
      Dir.chdir('inspector-status') do
        system 'bundle', 'install'
        system './inspector.rb', '--target-tags', 'InspectorAuditable:true',
               '--aws-name-prefix', 'AWS-DEVSECOPS-WORKSHOP',
               '--failure-metrics', 'numeric_severity:9',
               '--asset-duration', '60',
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
