# Tooling in the DevSecOps Pipeline
Here are some pointers to jump right into learning with!

## Tests
There are an array of test suites in use, here's where you can find the test scenarios and steps.

### Integration Tests - Application
* Cucumber

Steps: `features/step_definitions/webserver.rb`

Scenario: `features/webserver.feature`

### Integration Tests - Security/Inspector
* inspector-status

You can adjust the test duration, rules to run, tags to test and the metrics to instrument.

Tooling: `pipeline/lib/pipeline/inspector.rb`

### Integration Tests - Security/ConfigRules
* config-rule-status

There are no adjustments to this test suite.

### Capacity Tests - Performance
* Cucumber

Tooling: `pipeline/lib/pipeline/capacity.rb`

Steps: `features/step_definitions/capacity_test.rb`

Scenario: `features/capacity_test.feature`

### Capacity Tests - Security/Penetration
* Cucumber

Steps: `features/steps/penetration_test.py`

Scenario: `features/penetration_test.feature`

### Infrastructure Tests
* Serverspec / RSpec Expectations

Steps:
* `test/integration/serverspec/spec/nginx/nginx_spec.rb`
* `test/integration/serverspec/spec/server/server_spec.rb`

