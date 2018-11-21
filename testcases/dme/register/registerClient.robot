*** Settings ***
Documentation   successfully register client

Library         MexDme  dme_address=${dme_api_address}

#Test Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0

*** Test Cases ***
Register client
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
