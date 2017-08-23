require 'aws-sdk'

module Pipeline
  # Class for handling ConfigService tests
  class ConfigService
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION']
      @params[:region] ||= 'us-east-1'
      @configservice = Aws::ConfigService::Client.new(region: @params[:region])

      report_config_status
    end

    def report_config_status
      ENV['AWS_REGION'] ||= 'us-east-1'

      puts("\n\n=== AWS ConfigService Report ===\n\n")
      @configservice.describe_config_rules.config_rules.each do |rule|
        puts("\n")
        p(rule.config_rule_name)
        p(rule.description)
        compliance = @configservice.describe_compliance_by_config_rule(config_rule_names: [rule.config_rule_name])
        unless compliance.compliance_by_config_rules[0].compliance.compliance_type.nil?
          p(compliance.compliance_by_config_rules[0].compliance.compliance_type)
        end
        unless compliance.compliance_by_config_rules[0].compliance.compliance_contributor_count.nil?
          print('Number of violations: ')
          p(compliance.compliance_by_config_rules[0].compliance.compliance_contributor_count.capped_count)
        end
      end
    end
  end
end
