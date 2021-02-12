*** Settings ***
Documentation  RegisterClient multiple times

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables  shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0

${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
#${token_server_local_url}  http://127.0.0.1:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

*** Test Cases ***
# ECQ-1103
RegisterClient - register shall work when keep creating/deleting same app instance 
   [Documentation]
   ...  Create app instance
   ...  register client
   ...  delete/readd app instance
   ...  register client again to same app instance
   ...  repeat 10 times 

   # EDGECLOUD-410 - RegisterClient fails if deleting and then re-adding the same app instance

   ${developer_name_default}=  Get Default Developer Name
   ${app_name_default}=        Get Default App Name
   ${app_version_default}=     Get Default App Version

   FOR  ${INDEX}  IN RANGE  0  10
     ${appinst}=  Create App Instance         cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  no_auto_delete=True  cluster_instance_name=autocluster

     Register Client	
     ${decoded_cookie}=  decoded session cookie
     ${token_server}=    token server uri

#   \  ${status}  ${value}=  Run Keyword And Ignore Error  Should Contain  %{AUTOMATION_DME_ADDRESS}  127.0.0.1
#   \  Run Keyword If   '${status}' == 'PASS'   Should Be Equal  ${token_server}  ${token_server_local_url}
#   \  ...  ELSE  Should Be Equal  ${token_server}  ${token_server_url}

     Should Be Equal  ${token_server}  ${token_server_url}
     ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
     Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
     Should Match Regexp  ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
     Should Be Equal  ${decoded_cookie['key']['orgname']}  ${developer_name_default}	
     Should Be Equal  ${decoded_cookie['key']['appname']}  ${app_name_default}	
     Should Be Equal  ${decoded_cookie['key']['appvers']}  ${app_version_default}	
 
     Delete App Instance         cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
     Delete Cluster Instance     cluster_name=${appinst.real_cluster_name}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
   END

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    #Create Developer            
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    #Create Cluster
    Create App                  

