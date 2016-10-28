#!/usr/bin/env ruby

require 'aws-sdk'
require 'pipeline/cfn_helper'

# Pipeline
module Pipeline
  # Provides helper methods for provisioning
  class CloudFormationHelper
    def cfn_parameters(template_name)
      template_path = "provisioning/cloudformation/#{template_name}.template"
      {
        stack_name: stack_name,
        template_body: File.read(template_path),
        parameters: stack_parameters
      }
    end

    def parameter(key, value)
      {
        parameter_key: key,
        parameter_value: value
      }
    end

    def waiter(waiter_name)
      started_at = Time.now

      @cloudformation.wait_until(waiter_name, stack_name: stack_name) do |w|
        w.max_attempts = nil
        w.before_wait do
          throw :failure if Time.now - started_at > 600
        end
      end

      sleep 180 if waiter_name == :stack_create_complete
    end

    def keypair
      return '' if @params[:environment] == 'production'
      retrieve_or_generate_keypair
    end

    def retrieve_or_generate_keypair
      key_path = "#{stack_name}.pem"
      return stack_name if keypair_exists?(key_path)

      delete_old_keypair(key_path) # if keypair_exists?(key_path)

      key_material = @ec2.create_key_pair(key_name: stack_name).key_material
      File.write(key_path, key_material)
      File.chmod(0400, key_path)

      stack_name
    end

    def keypair_exists?(key_path)
      aws_check = !@ec2.describe_key_pairs(key_names: [stack_name])
                       .key_pairs.empty?
      aws_check && File.exist?(key_path)
    rescue Aws::EC2::Errors::InvalidKeyPairNotFound
      return false
    end

    def delete_old_keypair(key_path)
      @ec2.delete_key_pair(key_name: stack_name)
      File.delete(key_path) if File.exist?(key_path)
    rescue Aws::EC2::Errors::InvalidKeyPairNotFound => error
      puts error # noop
    rescue RuntimeError => error
      puts error # noop
    end

    def stack_exists
      @cloudformation.describe_stacks(stack_name: stack_name)
      return true
    rescue Aws::CloudFormation::Errors::ValidationError
      return false
    end

    def connector_sg
      @cloudformation.describe_stack_resource(
        stack_name: 'AWS-DEVSECOPS-WORKSHOP-JENKINS',
        logical_resource_id: 'JenkinsConnector'
      ).stack_resource_detail.physical_resource_id
    end
  end
end
