*** Settings ***
Documentation   Cluster CPU Metrics forbidden for Developer/Operator

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
		      
Test Setup       Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
${operator}=                       GDDT

${username_admin}=  mexadmin
${password_admin}=  mexadmin123


${username}=  mextester06 
${password}=  mextester06123 
${orgname}=   metricsorg
	
*** Test Cases ***
ClusterMetrics - OperatorManager shall not be able to get cluster CPU metrics
   [Documentation]
   ...  request the cluster CPU metrics as OperatorManager
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorManager   token=${adminToken}  #use_defaults=${False}

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=cluster_name  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=developer_name  selector=cpu  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

ClusterMetrics - OperatorContributor shall not be able to get cluster CPU metrics
   [Documentation]
   ...  request the cluster CPU metrics as OperatorContributor
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorContributor   token=${adminToken}

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=cluster_name  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=developer_name  selector=cpu  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

ClusterMetrics - OperatorViewer shall not be able to get cluster CPU metrics
   [Documentation]
   ...  request the cluster CPU metrics as OperatorViewer
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=OperatorViewer   token=${adminToken}

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=cluster_name  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=developer_name  selector=cpu  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

ClusterMetrics - DeveloperManager shall not be able to get cluster CPU metrics from another organization
   [Documentation]
   ...  request the cluster CPU metrics as DeveloperManager for another organization
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperManager   token=${adminToken}  #use_defaults=${False}

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=andycluster  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=automation_api  selector=cpu  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

ClusterMetrics - DeveloperContributor shall not be able to get cluster CPU metrics from another organization
   [Documentation]
   ...  request the cluster CPU metrics as DeveloperContributor for another organization
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperContributor  token=${adminToken}  #use_defaults=${False}

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=andycluster  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=automation_api  selector=cpu  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}

ClusterMetrics - DeveloperViewer shall not be able to get cluster CPU metrics from another organization
   [Documentation]
   ...  request the cluster CPU metrics as DeveloperViewer for another organization
   ...  verify forbidden is returned

   Create Org  orgname=${orgname}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername}  role=DeveloperViewer  token=${adminToken}  #use_defaults=${False}

   Run Keyword and Expect Error  *  Get Cluster Metrics  region=US  cluster_instance_name=andycluste  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  developer_name=automation_api  selector=cpu  token=${userToken}

   ${status_code}=  Response Status Code
   ${body} =        Response Body

   Should Be Equal As Integers  ${status_code}  403
   Should Be Equal              ${body}         {"message":"Forbidden"}
	
*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
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

