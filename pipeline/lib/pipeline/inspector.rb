# frozen_string_literal: true

require 'fileutils'

module Pipeline
  # Class for handling inspector tests
  class Inspector
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION']
      @params[:region] ||= 'us-east-1'
      run_inspector
    end

    def run_inspector
      puts("\n\n=== AWS Inspector Report ===\n\n")
      template_arn = File.read('/var/lib/jenkins/jenkins_inspector_assessment_template_arn').strip
      inspector = Aws::Inspector::Client.new(region: @params[:region])
      assessment_run = inspector.start_assessment_run(assessment_template_arn: template_arn)
      sleep(30) until inspector.describe_assessment_runs(
        assessment_run_arns: [assessment_run.assessment_run_arn]
      ).assessment_runs[0].state == 'COMPLETED'
      findings = inspector.list_findings(assessment_run_arns: [assessment_run.assessment_run_arn], max_results: 7)
      findings_detail = inspector.describe_findings(finding_arns: findings.finding_arns)
      findings_detail.findings.each do |f|
        puts "\n\nid: #{f.id}"
        puts "title: #{f.title}"
        puts "description: #{f.description}"
        puts "recommendation: #{f.recommendation}"
        puts "severity: #{f.severity}"
        puts "numeric_severity: #{f.numeric_severity}"
        puts "confidence: #{f.confidence}"
        puts "indicator_of_comprimise: #{f.indicator_of_compromise}\n\n"
      end
    end
  end
end
