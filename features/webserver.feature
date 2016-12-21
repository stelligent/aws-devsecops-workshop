Feature: Webserver is serving web pages
  @acceptance
  Scenario: Webserver is working
    Given that the "acceptance" server has a public IP address
    And that the server is responding to requests on port 80
    Then the webpage index should display "Stelligent Chat"

  @production
  Scenario: Webserver is working
    Given that the "production" server has a public IP address
    And that the server is responding to requests on port 80
    Then the webpage index should display "Stelligent Chat"
