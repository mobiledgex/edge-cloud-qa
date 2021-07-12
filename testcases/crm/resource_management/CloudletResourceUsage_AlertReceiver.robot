*** Settings ***
Documentation  CreateAlertReceiver on CRM

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}    #auto_login=${False}
Library  MexApp
Library  String
Library  DateTime
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  25m

*** Variables ***
${username}=  qaadmin
${password}=  zudfgojfrdhqntzm
${mexadmin_password}=  mexadminfastedgecloudinfra
${email}=  mxdmnqa@gmail.com


${user_username}=  mextester06
${user_password}=  mextester06123mobiledgexisbadass
${dev_password}=  mexadminfastedgecloudinfra

${slack_channel}=  channel
${slack_api_url}=  api

${region}=  EU
${operator_name_openstack}  TDG
${physical_name_openstack}  munich

${developer}=  ${developer_org_name_automation}

${latitude}       32.7767
${longitude}      -96.7970

${email_wait}=  300
${email_not_wait}=  30

*** Test Cases ***
# ECQ-3361
AlertReceiver - shall be able to create/receive email/slack CloudletResourceUsage alerts
   [Documentation]
   ...  - create a new user
   ...  - create alert reciever with cloudlet name and operator org for email and slack
   ...  - create cloudlet with one resource quota
   ...  - create docker dedicated cluster instance
   ...  - Verify CloudletResourceUsage firing alert and email/slack are generated
   ...  - Update Cloudlet to add other resource quotas
   ...  - Verify CloudletResourceUsage firing alert and email/slack are generated

   ${super_token}=  Get Super Token

   # create a new user
   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${user_password}   email_address=${emailepoch}
   Unlock User  token=${super_token}  username=${epochusername}
   Adduser Role  username=${epochusername}  orgname=${operator_name_openstack}  role=OperatorManager  token=${super_token}
   ${op_token}=  Login  username=${epochusername}  password=${user_password}
   ${dev_token}=  Login  username=dev_manager_automation  password=${dev_manager_password_automation}
   Set Suite Variable  ${op_token}

   # create email and slack alert as the new user
   Create Alert Receiver  token=${op_token}  receiver_name=${recv_name}_1  type=email  severity=info  email_address=${email}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}
   Create Alert Receiver  token=${op_token}  receiver_name=${recv_name}_2  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}

   &{resource1}=  Create Dictionary  name=RAM  value=14336  alert_threshold=75
   @{resource_list}=  Create List  ${resource1}

   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  resource_list=${resource_list}  token=${op_token} 

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor_name}  token=${dev_token}
   Log To Console  Done Creating Cluster Instance
   Verify Resource Usage  4  14336  8  CurrentUsage

   Alert Receiver Email For Firing CloudletResourceUsage Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}_1  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}  wait=${email_wait}  description=More than 75% of RAM is used by the cloudlet
   Alert Receiver Slack Message For Firing CloudletResourceUsage Should Be Received  region=${region}  alert_receiver_name=${recv_name}_2  cloudlet_name=${cloudlet_name}   operator_org_name=${operator_name_openstack}  wait=120  description=More than 75% of RAM is used by the cloudlet

   #Verify Soft Alert
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 75% of RAM is used by the cloudlet  token=${op_token}
   Should Not Be Empty  ${alert1[0]['data']}

   &{resource1}=  Create Dictionary  name=vCPUs  value=8    alert_threshold=80
   Append To List  ${resource_list}  ${resource1}

   Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${op_token}

   Alert Receiver Email For Firing CloudletResourceUsage Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}_1  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}  wait=${email_wait}  description=More than 80% of vCPUs is used by the cloudlet
   Alert Receiver Slack Message For Firing CloudletResourceUsage Should Be Received  region=${region}  alert_receiver_name=${recv_name}_2  cloudlet_name=${cloudlet_name}   operator_org_name=${operator_name_openstack}  wait=120  description=More than 80% of vCPUs is used by the cloudlet

   ${alert2}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 80% of vCPUs is used by the cloudlet  token=${op_token}
   Should Not Be Empty  ${alert2[0]['data']}

   &{resource1}=  Create Dictionary  name=Instances  value=4  alert_threshold=90
   Append To List  ${resource_list}  ${resource1}

   Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${op_token}

   Alert Receiver Email For Firing CloudletResourceUsage Should Be Received  email_password=${password}  email_address=${email}  alert_receiver_name=${recv_name}_1  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}  wait=${email_wait}  description=More than 90% of Instances is used by the cloudlet
   Alert Receiver Slack Message For Firing CloudletResourceUsage Should Be Received  region=${region}  alert_receiver_name=${recv_name}_2  cloudlet_name=${cloudlet_name}   operator_org_name=${operator_name_openstack}  wait=120  description=More than 90% of Instances is used by the cloudlet

   ${alert4}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 90% of Instances is used by the cloudlet  token=${op_token}
   Should Not Be Empty  ${alert4[0]['data']}


*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${user_username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${user_username}  ${epoch}

   Login  username=${username}  password=${mexadmin_password} 
   Create Flavor  region=${region}

   ${flavor_name}=  Get Default Flavor Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${cluster_name}=  Get Default Cluster Name
   ${recv_name}=  Get Default Alert Receiver Name

   Set Suite Variable  ${flavor_name}
   Set Suite Variable  ${recv_name}
   Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${emailepoch}
   Set Suite Variable  ${epoch}
   Set Suite Variable  ${epochusername}
   Set Suite Variable  ${cloudlet_name}

Verify Resource Usage
   [Arguments]  ${instances}  ${ram}  ${vcpu}  ${type}

   @{resource_list}=  Create List  ${instances}  ${ram}  ${vcpu}
   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${op_token}
   log to console  ${resource_usage}

   Run Keyword If  '${type}' == 'CurrentUsage'   Verify Current Usage  ${resource_list}  ${resource_usage}
   ...  ELSE  Verify Quota Limits  ${resource_list}  ${resource_usage}

Verify Current Usage
   [Arguments]  ${resourcelist}  ${resourceusage}

   #Should Be Equal As Numbers  ${resourceusage[0]['info'][0]['value']}  ${resourcelist[0]}            #Disk
   Should Be Equal As Numbers  ${resourceusage[0]['info'][3]['value']}  ${resourcelist[0]}            #Instances
   Should Be Equal As Numbers  ${resourceusage[0]['info'][4]['value']}  ${resourcelist[1]}            #RAM
   Should Be Equal As Numbers  ${resourceusage[0]['info'][5]['value']}  ${resourcelist[2]}            #vCPUs

Verify Quota Limits
   [Arguments]  ${resourcelist}  ${resourceusage}

   #Should Be Equal As Numbers  ${resourceusage[0]['info'][0]['quota_max_value']}  ${resourcelist[0]}            #Disk
   Should Be Equal As Numbers  ${resourceusage[0]['info'][3]['quota_max_value']}  ${resourcelist[0]}            #Instances
   Should Be Equal As Numbers  ${resourceusage[0]['info'][4]['quota_max_value']}  ${resourcelist[1]}            #RAM
   Should Be Equal As Numbers  ${resourceusage[0]['info'][5]['quota_max_value']}  ${resourcelist[2]}            #vCPUs

