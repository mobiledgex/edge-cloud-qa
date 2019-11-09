*** Settings ***
Documentation   Cloudlet Utilization Metrics for Developer

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
		      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBonnCloudlet
${operator}=                       TDG

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06 
${password}=  mextester06123 
${orgname}=   metricsorg
	
*** Test Cases ***
Metrics - DeveloperManager shall not be able to get cloudlet utilization metrics
   [Documentation]
   ...  request the cloudlet utilization metrics as DeveloperManager
   ...  verify forbidden is returned

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

Metrics - DeveloperContributor shall not be able to get cloudlet utilization metrics
   [Documentation]
   ...  request the cloudlet utilization metrics as DeveloperContributor
   ...  verify forbidden is returned

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperContributor   token=${adminToken}

   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

Metrics - DeveloperViewer shall not be able to get cloudlet utilization metrics
   [Documentation]
   ...  request the cloudlet utilization metrics as DeveloperViewer
   ...  verify forbidden is returned

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperViewer   token=${adminToken}

   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}
	
*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   Verify Email  email_address=${emailepoch}

   Create Org  orgname=${orgname}

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}


   Set Suite Variable  ${userToken}
   Set Suite Variable  ${adminToken}
   Set Suite Variable  ${epochusername}

