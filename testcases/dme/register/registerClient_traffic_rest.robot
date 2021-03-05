*** Settings ***
Documentation  RegisterClient multiple times

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
	
Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0

${latitude}	  31
${longitude}	  -91

#${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
#${token_server_local_url}  http://127.0.0.1:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

${number_batches}   10
${number_requests}  50

${region}=  US
	
*** Test Cases ***
# ECQ-2729
RegisterClient - DME should handle simultaneous register requests 
   [Documentation]
   ...  Send simultaneous Register messages to the DME
   ...  Verify all are successful

   FOR  ${x}  IN RANGE  0  ${number_batches}
      Send Register
   END

   ${total}=    Number of Register Requests
   ${success}=  Number of Successful Register Requests
   ${fail}=     Number of Failed Register Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

# ECQ-2730
FindCloudlet - DME should handle simultaneous FindCloudlet requests 
   [Documentation]
   ...  Send simultaneous FindCloudlet messages to the DME
   ...  Verify all are successful

   Register Client

   FOR  ${x}  IN RANGE  0  ${number_batches}
      Send FindCloudlet
   END

   ${total}=    Number of Find Cloudlet Requests
   ${success}=  Number of Successful Find Cloudlet Requests
   ${fail}=     Number of Failed Find Cloudlet Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

# ECQ-2371
VerifyLocation - DME should handle simultaneous VerifyLocation requests 
   [Documentation]
   ...  Send simultaneous VerifyLocation messages to the DME
   ...  Verify all are successful

   Register Client
   MexDmeRest.Get Token

   FOR  ${x}  IN RANGE  0  ${number_batches}
      Send Verify Location
   END

   ${total}=    Number of Verify Location Requests
   ${success}=  Number of Successful Verify Location Requests
   ${fail}=     Number of Failed Verify Location Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}
	
   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

# ECQ-2737
RegisterClient - DME should handle simultaneous register requests for multiple apps
   [Documentation]
   ...  Send simultaneous Register messages to the DME for multiple apps
   ...  Verify all are successful

   ${time}=  Get time  epoch

   # create 10 apps
   FOR  ${x}  IN RANGE  0  ${number_batches}
      Create App  region=${region}  app_name=app${time}${x}
   END

   FOR  ${x}  IN RANGE  0  ${number_batches}
      Send Register  app_name=app${time}${x}
   END

   ${total}=    Number of Register Requests
   ${success}=  Number of Successful Register Requests
   ${fail}=     Number of Failed Register Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}

   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

# ECQ-2738
FindCloudlet - DME should handle simultaneous FindCloudlet requests for multiple apps
   [Documentation]
   ...  Send simultaneous FindCloudlet messages to the DME for multiple apps
   ...  Verify all are successful

   ${time}=  Get time  epoch

   #create 10 apps
   FOR  ${x}  IN RANGE  0  ${number_batches}
      Create App  region=${region}  app_name=app${time}${x}
      Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
   END

   FOR  ${x}  IN RANGE  0  ${number_batches}
      Register Client  app_name=app${time}${x}
      Send FindCloudlet
   END

   ${total}=    Number of Find Cloudlet Requests
   ${success}=  Number of Successful Find Cloudlet Requests
   ${fail}=     Number of Failed Find Cloudlet Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}

   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

# ECQ-2379
VerifyLocation - DME should handle simultaneous VerifyLocation requests for multiple apps
   [Documentation]
   ...  Send simultaneous VerifyLocation messages to the DME for multiple apps
   ...  Verify all are successful

   ${time}=  Get time  epoch

   #create 10 apps
   FOR  ${x}  IN RANGE  0  ${number_batches}
      Create App  region=${region}  app_name=app${time}${x}
      Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
   END

   #Register Client
   #Get Token

   FOR  ${x}  IN RANGE  0  ${number_batches}
      Register Client  app_name=app${time}${x}
      MexDmeRest.Get Token
      Send Verify Location
   END

   ${total}=    Number of Verify Location Requests
   ${success}=  Number of Successful Verify Location Requests
   ${fail}=     Number of Failed Verify Location Requests

   ${total_total}=    Evaluate  ${number_requests}*${number_batches}

   Should Be Equal As Numbers  ${total}  ${total_total}
   Should Be Equal As Numbers  ${success}  ${total_total}
   Should Be Equal As Numbers  ${fail}  0

*** Keywords ***
Setup
    Create Flavor  region=${region}
    Create App  region=${region}                 
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

Send Register
   [Arguments]  ${app_name}=${None}

   @{handle_list}=  Create List
	
   FOR  ${INDEX}  IN RANGE  0  ${number_requests}
      ${handle}=  Register Client  app_name=${app_name}  use_thread=${True}
      Append To List  ${handle_list}  ${handle}
   END
	
   MexDmeRest.Wait For Replies  @{handle_list}
	
Send FindCloudlet
   @{handle_list}=  Create List
	
   FOR  ${INDEX}  IN RANGE  0  ${number_requests}
      ${handle}=  Find Cloudlet	carrier_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  use_thread=${True}
      Append To List  ${handle_list}  ${handle}
   END
	
   MexDmeRest.Wait For Replies  @{handle_list}

Send VerifyLocation
   @{handle_list}=  Create List
	
   FOR  ${INDEX}  IN RANGE  0  ${number_requests}
      ${handle}=  Verify Location  carrier_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  use_thread=${True}
      Append To List  ${handle_list}  ${handle}
   END
	
   MexDmeRest.Wait For Replies  @{handle_list}
