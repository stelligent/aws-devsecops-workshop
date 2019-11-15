# frozen_string_literal: true

require_relative '../spec_helper'
require 'cfn-model'
require 'cfn_nag/lib/cfn-nag/custom_rules/InternetGatewayRule'

describe InternetGatewayRule do
  context 'When an AWS::EC2::InternetGateway resource exists in a CloudFormation template' do
    it 'returns logical resource ID for the offending InternetGateway' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/vpc/internet_gateway_exists.yaml'
      )

      actual_logical_resource_ids = InternetGatewayRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[InternetGateWay]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'When an AWS::EC2::InternetGateway resource does not exist in a CloudFormation template' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/vpc/internet_gateway_does_not_exst.yaml'
      )

      actual_logical_resource_ids = InternetGatewayRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
