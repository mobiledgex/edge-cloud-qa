*** Settings ***
Documentation   UpdateApp port range fail

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
UpdateApp - update with UDP:0 shall return error 
   [Documentation]
   ...  create an app 
   ...  update the app with udp port 0 
   ...  verify proper error is returned

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=udp:0
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"} 

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:3,udp:0
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=udp:0-10
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=udp:10,udp:0
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

UpdateApp - update with TCP:0 shall return error
   [Documentation]
   ...  create an app
   ...  update the app with tcp port 0
   ...  verify proper error is returned

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:0
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=udp:3,tcp:0
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:0-10
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:1234,tcp:0
   Should Contain  ${error}  code=400
   Should Contain  ${error}  error={"message":"App ports out of range"}

# http no longer supported
#UpdateApp - update with HTTP:0 shall return error
#   [Documentation]
#   ...  create an app
#   ...  update the app with http port 0
#   ...  verify proper error is returned
#
#   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=http:0
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  error={"message":"App ports out of range"}
#
#   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=udp:3,tcp:1,http:0
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  error={"message":"App ports out of range"}
#
#   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=http:0-10
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  error={"message":"App ports out of range"}
#
#   ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=http:1234,http:0
#   Should Contain  ${error}  code=400
#   Should Contain  ${error}  error={"message":"App ports out of range"}

*** Keywords ***
Setup
    Create Flavor  region=US
    Create App     region=US  access_ports=udp:1
