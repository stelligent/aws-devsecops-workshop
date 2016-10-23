Feature: Webserver is serving web pages
  Scenario: Webserver is working
    Given that a server has a public IP address
    And that the server is responding to requests on port 80
    Then the webpage index should display "Welcome to nginx!"
