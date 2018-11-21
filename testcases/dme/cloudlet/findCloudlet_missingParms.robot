*** Settings ***
Documentation  RegisterClient with missing parameters
...   attempt to register a client with various combinations of missing parameters

Library  MexDme  dme_address=${dme_api_address}

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication
${app_name_auth}  someapplicationAuth
${developer_name}  AcmeAppCo
${app_version}  1.0
${carrier_name}  tmus

*** Test Cases ***
#EDGECLOUD-141
FindCloudlet - request should return '' with carrier_name only
   ${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}

   Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet	carrier_name=${carrier_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "DevName cannot be empty"

FindCloudlet - request should return '' with latitude and longitude only
#EDGECLOUD-285
   ${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}

   Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet	latitude=35  longitude=-90

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "DevName cannot be empty"

FindCloudlet - request should return '' with latitude only

FindCloudlet - request should return '' with longitude only

FindCloudlet - request should return '' with carrier_name and latitude only

FindCloudlet - request should return '' with carrier_name and longitude only

