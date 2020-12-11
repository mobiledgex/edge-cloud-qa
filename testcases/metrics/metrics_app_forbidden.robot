*** Settings ***
Documentation   App Metrics forbidden for Developer/Operator

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
		      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationSunnydaleCloudletStage
${operator}=                       GDDT

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06 
${password}=  ${mextester06_gmail_password} 
#${orgname}=   metricsorg 
	
*** Test Cases ***
AppMetrics - OperatorManager shall not be able to get app metrics
   [Documentation]
   ...  request the app metrics as OperatorManager
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorManager   token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}  last=5
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=connections  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

AppMetrics - OperatorContributor shall not be able to get app metrics
   [Documentation]
   ...  request the app metrics as OperatorContributor
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorContributor   token=${adminToken}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=connections  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

AppMetrics - OperatorViewer shall not be able to get app metrics
   [Documentation]
   ...  request the app metrics as OperatorViewer
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorViewer   token=${adminToken}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=connections  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=EU  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

AppMetrics - DeveloperManager shall not be able to get app metrics from another org
   [Documentation]
   ...  request the app metrics as DeveloperManager for another org
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=connections  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

AppMetrics - DeveloperContributor shall not be able to get app metrics from another org
   [Documentation]
   ...  request the app metrics as DeveloperContributor for another org
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperContributor  token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=connections  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

AppMetrics - DeveloperViewer shall not be able to get app metrics from another org
   [Documentation]
   ...  request the app metrics as DeveloperViewer for another org
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperViewer  token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=connections  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get App Metrics  region=US  app_name=automation_api_app  app_version=1.0  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  error={"message":"Forbidden"}

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${orgname}=  Catenate  SEPARATOR=  org  ${epoch}
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   #Verify Email  email_address=${emailepoch}

   #Create Org  orgname=${orgname}

   ${userToken}=  Login  username=${epochusername}  password=${password}
   ${adminToken}=  Login  username=${username_admin}  password=${password_admin}

   Set Suite Variable  ${orgname}
   Set Suite Variable  ${userToken}
   Set Suite Variable  ${adminToken}
   Set Suite Variable  ${epochusername}

