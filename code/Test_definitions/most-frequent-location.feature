Feature: CAMARA Most Frequent Location API, vwip
  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * List of device identifier types which are not supported, among: phoneNumber, ipv4Address, ipv6Address.
  # * List of application server ip formats which are not supported, among ipv4 and ipv6.
  #   For this version, CAMARA does not allow the use of networkAccessIdentifier, so it is considered by default as not supported.
  #
  # Testing assets:
  # * A device object applicable for Most Frequent Location service.
  # * A device object identifying a device commercialized by the implementation for which the service is not applicable, if any.

  # References to OAS spec schemas refer to schemas specifies in most-frequent-location.yaml

  Background: Common verifyFrequentLocation setup
    Given an environment at "apiRoot"
    And the resource "/most-frequent-location/vwip/verify"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    # Properties not explicitly overwritten in the Scenarios can take any values compliant with the schema
    And the request body is set by default to a request body compliant with the schema at "/components/schemas/VerifyFrequentLocationRequest"

  # Success scenarios

  @verifyFrequentLocation_01_generic_success_scenario
  Scenario: Common validations for any success scenario
    Given a valid testing device supported by the service, identified by the token or provided in the request body
    And the request body property "$.geoReference" is set to a valid geographical reference
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "/components/schemas/VerifyFrequentLocationResponse"

  # Scenarios testing specific situations

  @verifyFrequentLocation_02_success_with_coverage_zone
  Scenario: Successful response providing coverage zone
    Given a valid testing device supported by the service, identified by the token or provided in the request body
    And the request body property "$.geoReference.type" is set to "COVERAGE_ZONE"
    And the request body property "$.geoReference.latitude" is set to a valid number between -90 and 90
    And the request body property "$.geoReference.longitude" is set to a valid number between -180 and 180
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 200
    And the response contains the property "$.score" and its value represents the score of the location in the geoReference

  @verifyFrequentLocation_03_success_with_postal_code
  Scenario: Successful response providing postal code
    Given a valid testing device supported by the service, identified by the token or provided in the request body
    And the request body property "$.geoReference.type" is set to "POSTAL_CODE"
    And the request body property "$.geoReference.postalCode" is set to a valid zip or postal code
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 200
    And the response contains the property "$.score" and its value represents the score of the location in the geoReference

  # Errors 400

  @verifyFrequentLocation_400.1_invalid_argument
  Scenario: Invalid Argument. Generic Syntax Exception
    Given the request body is set to any value which is not compliant with the schema at "/components/schemas/VerifyFrequentLocationRequest"
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_400.2_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_400.3_empty_request_body
  Scenario: Empty object as request body
    Given the request body is set to "{}"
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_400.4_out_of_range
  Scenario Outline: Out of Range
    Given a valid testing device supported by the service, identified by the token or provided in the request body
    And the request body property "$.geoReference" is set to a valid geographical reference
    And the request body property "<property>" is set to a value that does not comply with the range defined in the OAS schema at "<oas_spec_schema>"
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "OUT_OF_RANGE" or "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | property                 | oas_spec_schema               |
      | $.geoReference.latitude  | /components/schemas/Latitude  |
      | $.geoReference.longitude | /components/schemas/Longitude |

  @verifyFrequentLocation_400.6_postal_code_not_valid
  Scenario: Postal Code not valid
    Given a valid testing device supported by the service, identified by the token or provided in the request body
    And the request body property "$.geoReference.postalCode" is set to a value that is compliant with the schema at "/components/schemas/PostalCode"
    And this value is not valid or is unknown for the Operator
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "MOST_FREQUENT_LOCATION.POSTAL_CODE_NOT_VALID"
    And the response property "$.message" contains a user friendly text

  # Generic 401 errors

  @verifyFrequentLocation_401.1_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    And the request body is set to a valid request body
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_401.2_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    And the request body is set to a valid request body
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_401.3_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    And the request body is set to a valid request body
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  # Errors 403

  @verifyFrequentLocation_403.1_invalid_token_permissions
  Scenario: Access token does not have the required permissions
    Given the header "Authorization" is set to an access token without the required scope
    When the request "verifyFrequentLocation" is sent
    Then the response status code is "403"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Errors 404

  @verifyFrequentLocation_404.1_information_not_available
  Scenario: Device information is not available
    Given a valid testing device supported by the service, identified by the token or provided in the request body
    And the request body property "$.geoReference" is set to a valid geographical reference
    And the geographical information of this device is not available or is not enough to calculate the score
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 404
    And the response property "$.status" is 404
    And the response property "$.code" is "MOST_FREQUENT_LOCATION.INFORMATION_NOT_AVAILABLE"
    And the response property "$.message" contains a user friendly text

  # Error scenarios for management of input parameter device

  @verifyFrequentLocation_C01.01_device_empty
  Scenario: The device value is an empty object
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is set to: {}
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_C01.02_device_identifiers_not_schema_compliant
  Scenario Outline: Some device identifier value does not comply with the schema
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "<device_identifier>" does not comply with the OAS schema at "<oas_spec_schema>"
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | device_identifier          | oas_spec_schema                             |
      | $.device.phoneNumber       | /components/schemas/PhoneNumber             |
      | $.device.ipv4Address       | /components/schemas/DeviceIpv4Addr          |
      | $.device.ipv6Address       | /components/schemas/DeviceIpv6Address       |
      | $.device.networkIdentifier | /components/schemas/NetworkAccessIdentifier |

  # This scenario may happen e.g. with 2-legged access tokens, which do not identify a single device.
  @verifyFrequentLocation_C01.03_device_not_found
  Scenario: Some identifier cannot be matched to a device
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is compliant with the schema but does not identify a valid device
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 404
    And the response property "$.status" is 404
    And the response property "$.code" is "IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @verifyFrequentLocation_C02.04_unnecessary_device
  Scenario: Device not to be included when it can be deduced from the access token
    Given the header "Authorization" is set to a valid access token identifying a device
    And the request body property "$.device" is set to a valid device
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "UNNECESSARY_IDENTIFIER"
    And the response property "$.message" contains a user-friendly text

  @verifyFrequentLocation_C01.05_missing_device
  Scenario: Device not included and cannot be deduced from the access token
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is not included
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "MISSING_IDENTIFIER"
    And the response property "$.message" contains a user-friendly text

  @verifyFrequentLocation_C01.06_unsupported_device
  Scenario: None of the provided device identifiers is supported by the implementation
    Given that some types of device identifiers are not supported by the implementation
    And the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" only includes device identifiers not supported by the implementation
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "UNSUPPORTED_IDENTIFIER"
    And the response property "$.message" contains a user-friendly text

  # When the service is only offered to certain types of devices or subscriptions, e.g. IoT, B2C, etc.
  @verifyFrequentLocation_C01.07_device_not_supported
  Scenario: Service not available for the device
    Given that the service is not available for all devices commercialized by the operator
    And a valid device, identified by the token or provided in the request body, for which the service is not applicable
    When the request "verifyFrequentLocation" is sent
    Then the response status code is 422
    And the response property "$.status" is 422
    And the response property "$.code" is "SERVICE_NOT_APPLICABLE"
    And the response property "$.message" contains a user-friendly text
