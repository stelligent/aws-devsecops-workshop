require 'aws-sdk'
require 'eat'
require 'pipeline/state'
require 'pipeline/cfn_helper'

# Pipeline
module Pipeline
  # Deployment class for all environments
  class Deploy < CloudFormationHelper
    def initialize(params = {})
      @params = params
      @cloudformation = Aws::CloudFormation::Client
                        .new(region: aws_region)
      @ec2 = Aws::EC2::Client.new(region: aws_region)

      deploy
    end

    def deploy
      return create_stack unless stack_exists
      update_stack
    end

    def create_stack
      @cloudformation.create_stack(cfn_parameters('deployment'))
      wait_and_save(:stack_create_complete)
    end

    def update_stack
      @cloudformation.update_stack(cfn_parameters('deployment'))
      wait_and_save(:stack_update_complete)
    end

    def stack_parameters
      [
        parameter('VPCID', ENV['VPCID']),
        parameter('SubnetId', ENV['SubnetId']),
        parameter('KeyPairName', keypair),
        parameter('Environment', @params[:environment]),
        parameter('JenkinsConnectorSG', connector_sg),
        parameter('WorldCIDR', ENV['WorldCIDR']),
        parameter('UUID', `uuidgen`.strip!)
      ]
    end

    def wait_and_save(waiter_name)
      waiter(waiter_name)
      save_stack_info
    end

    def save_stack_info
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'STACK_NAME',
                            value: stack_name)
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'WEBSERVER_IP',
                            value: public_ip)
      Pipeline::State.store(namespace: @params[:environment],
                            key: 'WEBSERVER_PRIVATE_IP',
                            value: private_ip)
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

    def private_ip
      stack = @cloudformation.describe_stacks(stack_name: stack_name)
                             .stacks.first

      stack.outputs.each do |output|
        return output.output_value if output.output_key == 'EC2PrivateIP'
      end
    end

    def stack_name
      "AWS-DEVSECOPS-WORKSHOP-DEPLOY-#{@params[:environment].upcase}"
    end
  end
end
