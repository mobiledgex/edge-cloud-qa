*** Settings ***
Documentation  RegisterClient multiple times

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  Collections
	
Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0

${latitude}	  31
${longitude}	  -91

#${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
#${token_server_local_url}  http://127.0.0.1:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

${number_batches}   10
${number_requests}  100
	
*** Test Cases ***
RegisterClient - DME should handle simultaneous register requests 
   [Documentation]
   ...  Send simultaneous Register messages to the DME
   ...  Verify all are successful

   : FOR  ${x}  IN RANGE  0  ${number_batches}
   \  Send Register

   ${total}=    Number of Register Requests
   ${success}=  Number of Successful Register Requests
   ${fail}=     Number of Failed Register Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

FindCloudlet - DME should handle simultaneous FindCloudlet requests 
   [Documentation]
   ...  Send simultaneous FindCloudlet messages to the DME
   ...  Verify all are successful

   Register Client

   : FOR  ${x}  IN RANGE  0  ${number_batches}
   \  Send FindCloudlet

   ${total}=    Number of Find Cloudlet Requests
   ${success}=  Number of Successful Find Cloudlet Requests
   ${fail}=     Number of Failed Find Cloudlet Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

VerifyLocation - DME should handle simultaneous VerifyLocation requests 
   [Documentation]
   ...  Send simultaneous VerifyLocation messages to the DME
   ...  Verify all are successful

   Register Client
   Get Token

   : FOR  ${x}  IN RANGE  0  ${number_batches}
   \  Send Verify Location

   ${total}=    Number of Verify Location Requests
   ${success}=  Number of Successful Verify Location Requests
   ${fail}=     Number of Failed Verify Location Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    Create Developer            
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create Cluster Flavor
    Create Cluster
    Create App                  
    Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

Send Register
   @{handle_list}=  Create List
	
   : FOR  ${INDEX}  IN RANGE  0  ${number_requests}
   \  ${handle}=  Register Client	use_thread=${True}
   \  Append To List  ${handle_list}  ${handle}
	
   MexDmeRest.Wait For Replies  @{handle_list}
	
Send FindCloudlet
   @{handle_list}=  Create List
	
   FOR  ${INDEX}  IN RANGE  0  ${number_requests}
   \  ${handle}=  Find Cloudlet	carrier_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  use_thread=${True}
   \  Append To List  ${handle_list}  ${handle}
	
   MexDmeRest.Wait For Replies  @{handle_list}

Send VerifyLocation
   @{handle_list}=  Create List
	
   FOR  ${INDEX}  IN RANGE  0  ${number_requests}
   \  ${handle}=  Verify Location  carrier_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  use_thread=${True}
   \  Append To List  ${handle_list}  ${handle}
	
   MexDmeRest.Wait For Replies  @{handle_list}
