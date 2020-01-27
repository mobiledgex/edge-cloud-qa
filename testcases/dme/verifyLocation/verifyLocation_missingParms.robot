*** Settings ***
Documentation  VerifyLocation with missing parameters
...   attempt to send VerifyLocation with various combinations of missing parameters

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${cloudlet_name}  tmocloud-2
${carrier_name}  tmus

*** Test Cases ***
VerifyLocation - request without lat/long should return 'Missing GpsLocation'
   [Documentation]  
   ...  send VerifyLocation with no latitude or longitude
   ...  verify 'Missing GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  carrier_name=${carrier_name}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Missing GPS location"

VerifyLocation - request without carrier should succeed
   [Documentation]
   ...  send VerifyLocation with no carrier
   ...  verify no error is received

   Register Client
   Get Token
   Verify Location  latitude=35  longitude=-90

VerifyLocation - request without token should return 'verifyloc token required'
   [Documentation]
   ...  send VerifyLocation with no token
   ...  verify 'verifyloc token required' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  session_cookie=default  latitude=35  longitude=-90  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   #Should Contain  ${error_msg}   details = "verifyloc token required"
   Should Contain  ${error_msg}   details = "no VerifyLocToken in request"

VerifyLocation - request with latitude only should not succeed
   [Documentation]
   ...  send VerifyLocation with carrier name and latitude only
   ...  verify error is received

   Register Client
   Get Token
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  session_cookie=default  carrier_name=tmus  token=default  latitude=35  use_defaults=${True}  # no error should be received

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

VerifyLocation - request with longitude only should not succeed
   [Documentation]
   ...  send VerifyLocation with carrier name and longitude only
   ...  verify error is received

   Register Client
   Get Token
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  session_cookie=default  carrier_name=${carrier_name}  longitude=35  use_defaults=${True}  # no error should be received

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

*** Keywords ***
Setup
    ${time}=  Get Time  epoch

    #Create Developer
    Create Flavor
    #Create Cluster
    Create App
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}  cluster_instance_name=autocluster${time}
