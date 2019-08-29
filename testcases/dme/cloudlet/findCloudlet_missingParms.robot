*** Settings ***
Documentation  FindCloudlet with missing parameters
...   attempt to register a client with various combinations of missing parameters

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
#${dme_api_address}  127.0.0.1:50051
#${app_name}  someapplication
#${app_name_auth}  someapplicationAuth
#${developer_name}  AcmeAppCo
#${app_version}  1.0
${cloudlet_name}  tmocloud-2
${carrier_name}  tmus

*** Test Cases ***
#EDGECLOUD-284
FindCloudlet - request without lat/long should return 'Missing GpsLocation'
   [Documentation]  
   ...  send FindCloudlet with no latitude or longitude
   ...  verify 'Missing GpsLocation' is received

   #${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}

   Register Client	#app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet	carrier_name=${carrier_name}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Missing GpsLocation"

FindCloudlet - request without carrier name should return 'missing carrierName'
   [Documentation]
   ...  send FindCloudlet with no carrier name
   ...  verify 'missing carrierName' is received

#EDGECLOUD-285
   #${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  session_cookie=default  latitude=35  longitude=-90  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Missing carrierName"

FindCloudlet - request with latitude only should return 'missing carrierName'
   [Documentation]
   ...  send FindCloudlet with latitude only
   ...  verify 'missing carrierName' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  session_cookie=default  latitude=35  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Missing carrierName"

FindCloudlet - request with longitude only should return 'missing carrierName'
   [Documentation]
   ...  send FindCloudlet with longitude only
   ...  verify 'missing carrierName' is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  session_cookie=default  longitude=35  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Missing carrierName"

FindCloudlet - request with carrier_name and latitude only should fail
   [Documentation]
   ...  send FindCloudlet with carrier name and latitude only
   ...  verify error is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  session_cookie=default  carrier_name=${carrier_name}  latitude=35  use_defaults=${False}  # no error should be received

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

FindCloudlet - request with carrier_name and longitude only should fail
   [Documentation]
   ...  send FindCloudlet with carrier name and longitude only
   ...  verify error is received

   Register Client
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  session_cookie=default  carrier_name=${carrier_name}  longitude=35  use_defaults=${False}  # no error should be received

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "Invalid GpsLocation"

*** Keywords ***
Setup
    #Create Operator             operator_name=${carrier_name} 
    Create Developer
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}
    #Create Cluster
    Create App
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${carrier_name}  cluster_instance_name=autocluster
