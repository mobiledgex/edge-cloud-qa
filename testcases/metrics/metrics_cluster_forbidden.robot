*** Settings ***
Documentation   Cluster Metrics forbidden for Developer/Operator

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
		      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationMunichCloudletStage
${operator}=                       TDG

${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}

${username}=  mextester06 
${password}=  ${mextester06_gmail_password} 
#${orgname}=   metricsorg 
	
*** Test Cases ***
ClusterMetrics - OperatorManager shall not be able to get cluster metrics
   [Documentation]
   ...  request the cluster metrics as OperatorManager
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorManager   token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}  last=5
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=tcp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=udp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=mobiledgex  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

ClusterMetrics - OperatorContributor shall not be able to get cluster metrics
   [Documentation]
   ...  request the cluster metrics as OperatorContributor
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorContributor   token=${adminToken}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=tcp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=udp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

ClusterMetrics - OperatorViewer shall not be able to get cluster metrics
   [Documentation]
   ...  request the cluster metrics as OperatorViewer
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorViewer   token=${adminToken}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=tcp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=udp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=EU  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

ClusterMetrics - DeveloperManager shall not be able to get cluster metrics from another org
   [Documentation]
   ...  request the cluster metrics as DeveloperManager for another org
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=tcp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=udp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

ClusterMetrics - DeveloperContributor shall not be able to get cluster metrics from another org
   [Documentation]
   ...  request the cluster metrics as DeveloperContributor for another org
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperContributor  token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=tcp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=udp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

ClusterMetrics - DeveloperViewer shall not be able to get cluster metrics from another org
   [Documentation]
   ...  request the cluster metrics as DeveloperViewer for another org
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperViewer  token=${adminToken}  #use_defaults=${False}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=cpu  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=disk  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=mem  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=tcp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=udp  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

   ${error}=  Run Keyword and Expect Error  *   Get Cluster Metrics  region=US  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  selector=network  token=${userToken}
   Should Contain  ${error}  code=403
   Should Contain  ${error}  {"message":"Forbidden"}

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
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

