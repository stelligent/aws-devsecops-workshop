# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class InternetGatewayRule < BaseRule
  def rule_text
    'Internet Gateways are not allowed'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W99'
  end

	def audit_impl(cfn_model)
    violating_resources = cfn_model.resources_by_type('AWS::EC2::InternetGateway')

		violating_resources.map(&:logical_resource_id)
	end  
end
