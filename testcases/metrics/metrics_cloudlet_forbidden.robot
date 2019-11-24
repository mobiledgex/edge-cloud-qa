*** Settings ***
Documentation   Cloudlet Utilization/IPUsage Metrics forbidden for Developer/Operator

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
		      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationSunnydaleCloudletStage
${operator}=                       GDDT

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06 
${password}=  mextester06123 
${orgname}=   metricsorg
	
*** Test Cases ***
CloudletMetrics - DeveloperManager shall not be able to get cloudlet metrics
   [Documentation]
   ...  request the cloudlet utilization/ipusage metrics as DeveloperManager
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   # get utilization metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

   # get ipusage metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=ipusage  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

CloudletMetrics - DeveloperContributor shall not be able to get cloudlet metrics
   [Documentation]
   ...  request the cloudlet utilization/ipusage metrics as DeveloperContributor
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperContributor   token=${adminToken}

   # get utilization metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

   # get ipusage metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=ipusage  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

CloudletMetrics - DeveloperViewer shall not be able to get cloudlet metrics
   [Documentation]
   ...  request the cloudlet utilization/ip metrics as DeveloperViewer
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperViewer   token=${adminToken}

   # get utilization metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

   # get ipusage metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=ipusage  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

CloudletMetrics - OperatorManager shall not be able to get cloudlet metrics from another operator
   [Documentation]
   ...  request the cloudlet utilization/ipusage metrics as OperatorManager for another operator
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorManager   token=${adminToken}  #use_defaults=${False}

   # get utilization metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

   # get ipusage metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=ipusage  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

CloudletMetrics - OperatorContributor shall not be able to get cloudlet metrics from another operator
   [Documentation]
   ...  request the cloudlet utilization/ipusage metrics as OperatorContributor for another operator
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorContributor  token=${adminToken}  #use_defaults=${False}

   # get utilization metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

   # get ipusage metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=ipusage  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

CloudletMetrics - OperatorViewer shall not be able to get cloudlet metrics from another operator
   [Documentation]
   ...  request the cloudlet utilization/ipusage metrics as OperatorViewer for another operator
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorViewer  token=${adminToken}  #use_defaults=${False}

   # get utilization metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=utilization  token=${userToken}
   ${status_code}=  Response Status Code
   ${body} =        Response Body
   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

   # get ipusage metrics
   Run Keyword and Expect Error  *   MexMasterController.Get Cloudlet Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=ipusage  token=${userToken}
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

   #Create Org  orgname=${orgname}

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Set Suite Variable  ${userToken}
   Set Suite Variable  ${adminToken}
   Set Suite Variable  ${epochusername}

