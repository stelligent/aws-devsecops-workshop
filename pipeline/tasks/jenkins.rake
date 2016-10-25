#!/usr/bin/env ruby

require 'aws-sdk'
require 'cfndsl'

region = ENV['AWS_REGION'] unless ENV['AWS_REGION'].nil?
region = 'us-east-1' if ENV['AWS_REGION'].nil?
@cloudformation = Aws::CloudFormation::Client.new(region: region)
@stack_name = "AWS-DEVSECOPS-WORKSHOP-JENKINS-#{ENV['USER'].upcase}"

namespace :jenkins do
  desc 'Create a Workshop Jenkins'
  task :create, [:vpc_id, :subnet_id, :world_cidr] do |_, opts|
    opts[:world_cidr] = '0.0.0.0/0'

    # Verify user input
    abort 'You must specify a VPC.' if opts[:vpc_id].nil?
    abort 'You must specify a Subnet.' if opts[:subnet_id].nil?
    world_cidr = opts[:world_cidr]
    world_cidr = '0.0.0.0/0' if world_cidr.nil?

    # Compile the template
    cfndsl_path = 'provisioning/cloudformation/jenkins.rb'
    cfn_template = CfnDsl.eval_file_with_extras(cfndsl_path).to_json

    # Create stack
    begin
      puts 'Creating Jenkins with CloudFormation (3-5 minutes)...'
      @cloudformation.create_stack(
        stack_name: @stack_name,
        template_body: cfn_template,
        capabilities: ['CAPABILITY_IAM'],
        parameters: [
          {
            parameter_key: 'VPCID',
            parameter_value: opts[:vpc_id]
          },
          {
            parameter_key: 'SubnetId',
            parameter_value: opts[:subnet_id]
          },
          {
            parameter_key: 'WorldCIDR',
            parameter_value: world_cidr
          }
        ]
      )
    rescue Aws::CloudFormation::Errors::AlreadyExistsException
      puts 'A Jenkins already exists in this region!'
    end

    # Wait for it to finish creating
    started_at = Time.now
    waiter = :stack_create_complete

    @cloudformation.wait_until(waiter, stack_name: @stack_name) do |w|
      w.max_attempts = nil
      w.before_wait do
        throw :failure if Time.now - started_at > 600
      end
    end

    jenkins_ip = @cloudformation.describe_stacks(stack_name: @stack_name)
                                .stacks.first.outputs.first.output_value

    puts "---- Jenkins URL: http://#{jenkins_ip}:8080/"
  end

  desc 'Teardown a Workshop Jenkins'
  task :teardown do
    puts "Tearing down Jenkins CloudFormation stack: #{@stack_name}"
    @cloudformation.delete_stack(stack_name: @stack_name)
  end
end
