require 'aws-sdk'

region = ENV['AWS_REGION'] unless ENV['AWS_REGION'].nil?
region = 'us-east-1' if ENV['AWS_REGION'].nil?
@cloudformation = Aws::CloudFormation::Client.new(region: region)
@stack_name = "AWS-DEVSECOPS-WORKSHOP-JENKINS-#{`uuidgen | cut -d- -f1`.strip!}"

namespace :jenkins do
  desc 'Create a Workshop VPC + Jenkins'
  # task :create, [:vpc_id, :subnet_id, :world_cidr] do |_, opts|
  task :create, [:world_cidr] do |_, opts|
    opts[:world_cidr] = '0.0.0.0/0'

    world_cidr = opts[:world_cidr]
    world_cidr = '0.0.0.0/0' if world_cidr.nil?

    # Compile the template
    cfn_template_path = 'provisioning/cloudformation/templates/workshop-jenkins'
    cfn_template = File.read("#{cfn_template_path}.json")

    # Create stack
    begin
      puts 'Creating VPC + Jenkins with CloudFormation (~15 minutes)...'
      @cloudformation.create_stack(
        stack_name: @stack_name,
        template_body: cfn_template,
        capabilities: %w[CAPABILITY_IAM CAPABILITY_NAMED_IAM],
        disable_rollback: true,
        parameters: [
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
        throw :failure if Time.now - started_at > 900
      end
    end

    jenkins_ip = @cloudformation.describe_stacks(stack_name: @stack_name)
                                .stacks.first.outputs
                                .select { |o| o.output_key == 'JenkinsIP' }
                                .first.output_value

    puts "---- Jenkins URL: http://#{jenkins_ip}:8080/"
  end

  desc 'Teardown a Workshop Jenkins'
  task :teardown do
    puts "Tearing down Jenkins CloudFormation stack: #{@stack_name}"
    @cloudformation.delete_stack(stack_name: @stack_name)
  end
end
