*** Settings ***
Documentation  RegisterClient - 'app not found' error should be recieved parameters that dont match any app instances

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables  shared_variables.py

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms

*** Test Cases ***
RegisterClient - request with wrong app_name shall return 'app not found'
   [Documentation]
   ...  send RegisterClient with app name that does not exist
   ...  verify 'app not found' error is received

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy

   Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
   Should Contain  ${error_msg}   details = "app not found"

RegisterClient - request with wrong app_version shall return 'app not found'
   [Documentation]
   ...  send RegisterClient with app name that exists but wrong app version 
   ...  verify 'app not found' error is received

   [Setup]  Setup

   ${developer_name_default}=  Get Default Developer Name
   ${app_name_default}=  Get Default App Name

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_default}  app_version=1.1  developer_name=${developer_name_default}

   Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
   Should Contain  ${error_msg}   details = "app not found"
   [Teardown]  Cleanup Provisioning

RegisterClient - request with wrong developer_name shall return 'app not found'
   [Documentation]
   ...  send RegisterClient with app name that exists but wrong developer
   ...  verify 'app not found' error is received

   [Setup]  Setup

   ${app_name_default}=        Get Default App Name
   ${app_version_default}=     Get Default App Version
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_default}  app_version=${app_version_default}  developer_name=dummy

   Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
   Should Contain  ${error_msg}   details = "app not found"

   [Teardown]  Cleanup Provisioning

RegisterClient - request with wrong app_name,app_version, and developer_name shall return 'app not found'
   [Documentation]
   ...  send RegisterClient with app name, app version and developer that doenst exist
   ...  verify 'app not found' error is received

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy  app_version=dummy  developer_name=dummy

   Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
   Should Contain  ${error_msg}   details = "app not found"

RegisterClient - request shall succeed after adding app
   [Documentation]
   ...  send RegisterClient with app that does not exist
   ...  verify 'app not found' is received
   ...  provision everything but an app
   ...  send RegisterClient again
   ...  verify 'app not found' is received since app inst is not added yet
   ...  provision app inst
   ...  send RegisgterClient again
   ...  register succeeds

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy
   Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
   Should Contain  ${error_msg}   details = "app not found"

   # create app and register again
   #Create Operator             operator_name=${operator_name}
   Create Developer
   Create Flavor
   #Create Cloudlet             cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
   #Create Cluster		
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client  app_name=dummy
   Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
   Should Contain  ${error_msg}   details = "app not found"

   ${developer_name_default}=  Get Default Developer Name
   ${app_version_default}=     Get Default App Version

   # add appinst and then register should pass
   Create App   app_name=dummy
   Register Client  app_name=dummy
   ${decoded_cookie}=  decoded session cookie
   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   Should Be Equal  ${decoded_cookie['key']['devname']}  ${developer_name_default}	
   Should Be Equal  ${decoded_cookie['key']['appname']}  dummy	
   Should Be Equal  ${decoded_cookie['key']['appvers']}  ${app_version_default}	
   Should Match Regexp  ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b

   [Teardown]  Cleanup provisioning

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    Create Developer            
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create Cluster
    Create App 
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

