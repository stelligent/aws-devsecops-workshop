#!/usr/bin/env ruby

require 'aws-sdk'
require 'eat'
require 'pipeline/state'

module Pipeline
  # Deployment class for all environments
  class Deploy
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION'] unless ENV['AWS_REGION'].nil?
      @params[:region] = 'us-east-1' if @params[:region].nil?
      @cloudformation = Aws::CloudFormation::Client
                        .new(region: @params[:region])
      @ec2 = Aws::EC2::Client.new(region: @params[:region])

      deploy
    end

    def deploy
      return create_stack unless stack_exists
      update_stack
    end

    def create_stack
      @cloudformation.create_stack(cfn_parameters)
      wait_and_save(:stack_create_complete)
    end

    def update_stack
      @cloudformation.update_stack(cfn_parameters)
      wait_and_save(:stack_update_complete)
    end

    def cfn_parameters
      template_path = 'provisioning/cloudformation/deployment.template'
      {
        stack_name: stack_name,
        template_body: File.read(template_path),
        parameters: stack_parameters
      }
    end

    def stack_parameters
      [
        parameter('VPCID', ENV['VPCID']),
        parameter('SubnetId', ENV['SubnetId']),
        parameter('KeyPairName', keypair),
        parameter('Environment', @params[:environment]),
        parameter('JenkinsSG', jenkins_sg),
        parameter('WorldCIDR', ENV['WorldCIDR'])
      ]
    end

    def parameter(key, value)
      {
        parameter_key: key,
        parameter_value: value
      }
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def wait_and_save(waiter)
      retries ||= 5
      started_at = Time.now

      @cloudformation.wait_until(waiter, stack_name: stack_name) do |w|
        w.max_attempts = nil
        w.before_wait do
          throw :failure if Time.now - started_at > 600
        end
      end

      sleep 180 if waiter == :stack_create_complete
      save_stack_info
    rescue Net::HTTPFatalError => exception
      retries -= 1
      sleep 10 if retries > 0
      retry if retries > 0
      raise "Unable to complete after 5 retries due to '#{exception.message}'"
    end

    def save_stack_info
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'STACK_NAME',
                            value: stack_name)
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'WEBSERVER_IP',
                            value: public_ip)
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'KEYPAIR_NAME',
                            value: stack_name)
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'KEYPAIR_PATH',
                            value: "#{stack_name}.pem")
    end

    def public_ip
      stack = @cloudformation.describe_stacks(stack_name: stack_name)
                             .stacks.first

      stack.outputs.each do |output|
        return output.output_value if output.output_key == 'EC2PublicIP'
      end
    end

    def jenkins_sg
      @cloudformation.describe_stack_resource(
        stack_name: 'AWS-DEVSECOPS-WORKSHOP-JENKINS',
        logical_resource_id: 'SecurityGroup'
      ).stack_resource_detail.physical_resource_id
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

    def stack_name
      "AWS-DEVSECOPS-WORKSHOP-DEPLOY-#{@params[:environment].upcase}"
    end
  end
end
