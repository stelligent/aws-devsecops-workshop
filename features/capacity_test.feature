Feature: Capacity Testing the Application
  Scenario: The application should fail no http requests
  Given we have a result set from Apache Benchmark
  Then there should be no failed requests
