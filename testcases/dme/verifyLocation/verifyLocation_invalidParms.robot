*** Settings ***
Documentation  VerifyLocation with invalid parameters
...   attempt to send VerifyLocation with various combinations of invalid parameters

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${cloudlet_name}  tmocloud-2
${carrier_name}  tmus

*** Test Cases ***
VerifyLocation - request with invalid low lat should return 'Invalid GpsLocation'
   [Documentation]  
   ...  send VerifyLocation with latitude=-91
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  carrier_name=${carrier_name}  latitude=-91  longitude=3

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

VerifyLocation - request with invalid high lat should return 'Invalid GpsLocation'
   [Documentation]
   ...  send VerifyLocation with latitude=91
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  carrier_name=${carrier_name}  latitude=91  longitude=3

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

VerifyLocation - request with invalid low long should return 'Invalid GpsLocation'
   [Documentation]
   ...  send VerifyLocation with longitude=-181
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  carrier_name=${carrier_name}  latitude=-9  longitude=-181

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

VerifyLocation - request with invalid high long should return 'Invalid GpsLocation'
   [Documentation]
   ...  send VerifyLocation with longitude=181
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  carrier_name=${carrier_name}  latitude=-9  longitude=181

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster
    Create App
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}  cluster_instance_name=autocluster
