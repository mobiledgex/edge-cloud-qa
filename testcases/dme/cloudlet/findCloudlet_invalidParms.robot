*** Settings ***
Documentation  FindCloudlet with out-of-range GPS parameters
...   attempt to send FindCloudlet with various combinations of out-of-range GPS parms

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${cloudlet_name}  tmocloud-2
${carrier_name}  tmus

*** Test Cases ***
FindCloudlet - request with too small latitude should return 'Invalid GpsLocation'
   [Documentation]  
   ...  send FindCloudlet with latitude of -91
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  carrier_name=${carrier_name}  latitude=-91  longitude=10

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

FindCloudlet - request with too large latitude should return 'Invalid GpsLocation'
   [Documentation]
   ...  send FindCloudlet with latitude of 91
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  carrier_name=${carrier_name}  latitude=91  longitude=10

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

FindCloudlet - request with too small longitude should return 'Invalid GpsLocation'
   [Documentation]
   ...  send FindCloudlet with longitude of -181 
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  carrier_name=${carrier_name}  latitude=1  longitude=-181

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

FindCloudlet - request with too large longitude should return 'Invalid GpsLocation'
   [Documentation]
   ...  send FindCloudlet with longitude of 181
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  carrier_name=${carrier_name}  latitude=1  longitude=181

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

FindCloudlet - request with out-of-range latitude/longitude should return 'Invalid GpsLocation'
   [Documentation]
   ...  send FindCloudlet with latitude=99999999999999999 and longitude of -99999999999999999
   ...  verify 'Invalid GpsLocation' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  carrier_name=${carrier_name}  latitude=99999999999999999  longitude=-99999999999999999

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

*** Keywords ***
Setup
    #Create Operator             operator_name=${carrier_name} 
    Create Developer
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}
    Create Cluster Flavor
    Create Cluster
    Create App
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}
