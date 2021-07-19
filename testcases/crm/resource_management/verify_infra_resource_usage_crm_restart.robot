*** Settings ***
Documentation  CloudletResourceUsage Alerts

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout    ${test_timeout_crm1}

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_openstack_packet}  packet
${physical_name_openstack_packet}  packet

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3390
Cloudletinfo displays correct infra usage and existing cluster instances after CRM restart
   [Documentation]
   ...  - Create Cloudlet with resource quotas and non default alert_thresholds
   ...  - Create Cluster Instance and verify current resource usage
   ...  - Infra usage displayed by cloudletinfo and getresourceusage must match
   ...  - Restart CRM server
   ...  - Infra usage displayed by cloudletinfo and getresourceusage must match
   ...  - Verify current resource usage

   &{resource1}=  Create Dictionary  name=RAM  value=14336  alert_threshold=75
   &{resource2}=  Create Dictionary  name=vCPUs  value=8    alert_threshold=80
   &{resource3}=  Create Dictionary  name=Instances  value=4  alert_threshold=90
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}


   # create cloudlet with resource quotas
   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  resource_list=${resource_list}  token=${tokenop}

   Verify Resource Usage  2  8192  4  CurrentUsage
   Verify Resource Usage  4  14336  8  MaxQuota

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  token=${tokendev}
   Verify Resource Usage   4  14336  8  CurrentUsage

   ${openstack_limits}=  Get Limits
   Log to Console  ${openstack_limits}
  
   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  infra_usage=${True}  token=${tokenop}

   FOR  ${x}  IN RANGE  0  30
       ${cloudlet_info}=   Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}      
       Exit For Loop If  '${cloudlet_info[0]['data']['resources_snapshot']['info'][3]['value']}' == '${resource_usage[0]['info'][3]['value']}'
       Sleep  10s
   END
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][3]['value']}              ${resource_usage[0]['info'][3]['value']}    #Instances
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][0]['value']}              ${resource_usage[0]['info'][4]['value']}    #RAM
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][1]['value']}              ${resource_usage[0]['info'][5]['value']}    #vCPUs
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['cluster_insts'][0]['cluster_key']['name']}  ${cluster_name}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['cluster_insts'][0]['organization']}   ${org_name_dev}

   ${crm_ip}=  Set Variable  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][0]['ipaddresses'][0]['externalIp']}
   Stop Crm Docker Container  crm_ip=${crm_ip}
   Start Crm Docker Container  crm_ip=${crm_ip}

   FOR  ${x}  IN RANGE  0  15
       ${cloudlet_info}=  Show Cloudlet Info   region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokenop}
       Exit For Loop If  '${cloudlet_info[0]['data']['state']}' == '2'
       Sleep  10s
   END
   Should Be Equal As Numbers   ${cloudlet_info[0]['data']['state']}  2

   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  infra_usage=${True}  token=${tokenop}

   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['cluster_insts'][0]['cluster_key']['name']}  ${cluster_name}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['cluster_insts'][0]['organization']}   ${org_name_dev}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][3]['value']}              ${resource_usage[0]['info'][3]['value']}    #Instances
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][0]['value']}              ${resource_usage[0]['info'][4]['value']}    #RAM
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][1]['value']}              ${resource_usage[0]['info'][5]['value']}    #vCPUs
   
   Verify Resource Usage   4  14336  8  CurrentUsage
 
*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${developer_name}=  Get Default Developer Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${org_name}=  Get Default Organization Name
   ${flavor}=  Get Default Flavor Name
   ${org_name_dev}=  Set Variable  ${org_name}_dev
   ${cluster_name}=  Get Default Cluster Name

   Create Flavor  region=${region}

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com
   ${usernamedev_epoch}=  Catenate  SEPARATOR=  ${username}  dev  ${epoch}
   ${emaildev}=  Catenate  SEPARATOR=  ${username}  dev  +  ${epoch}  @gmail.com

   Create Org  orgname=${org_name_dev}  orgtype=developer
   Create Billing Org  billing_org_name=${org_name_dev}  token=${token}

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack_packet}  role=OperatorManager  
   Adduser Role  username=${usernamedev_epoch}  orgname=${org_name_dev}  role=DeveloperContributor

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=${usernamedev_epoch}  password=${password}

   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}

   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${tokendev}

   Set Suite Variable  ${org_name_dev}

   Set Suite Variable  ${flavor}

Verify Resource Usage
   [Arguments]   ${instances}  ${ram}  ${vcpu}  ${type}

   @{resource_list}=  Create List  ${instances}  ${ram}  ${vcpu}
   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   log to console  ${resource_usage}

   Run Keyword If  '${type}' == 'CurrentUsage'   Verify Current Usage  ${resource_list}  ${resource_usage}
   ...  ELSE IF  '${type}' == 'MaxQuota'  Verify Quota Limits  ${resource_list}  ${resource_usage}
   ...  ELSE  Verify Infra Limits  ${resource_list}  ${resource_usage}

Verify Current Usage
   [Arguments]  ${resourcelist}  ${resourceusage}

   #Should Be Equal As Numbers  ${resourceusage[0]['info'][0]['value']}  ${resourcelist[0]}            #Disk
   Should Be Equal As Numbers  ${resourceusage[0]['info'][3]['value']}  ${resourcelist[0]}            #Instances
   Should Be Equal As Numbers  ${resourceusage[0]['info'][4]['value']}  ${resourcelist[1]}            #RAM
   Should Be Equal As Numbers  ${resourceusage[0]['info'][5]['value']}  ${resourcelist[2]}            #vCPUs

Verify Infra Limits
   [Arguments]  ${resourcelist}  ${resourceusage}

   #Should Be Equal As Numbers  ${resourceusage[0]['info'][0]['infra_max_value']}  ${resourcelist[0]}            #Disk
   Should Be Equal As Numbers  ${resourceusage[0]['info'][3]['infra_max_value']}  ${resourcelist[0]}            #Instances
   Should Be Equal As Numbers  ${resourceusage[0]['info'][4]['infra_max_value']}  ${resourcelist[1]}            #RAM
   Should Be Equal As Numbers  ${resourceusage[0]['info'][5]['infra_max_value']}  ${resourcelist[2]}            #vCPUs

Verify Quota Limits
   [Arguments]  ${resourcelist}  ${resourceusage}

   #Should Be Equal As Numbers  ${resourceusage[0]['info'][0]['quota_max_value']}  ${resourcelist[0]}            #Disk
   Should Be Equal As Numbers  ${resourceusage[0]['info'][3]['quota_max_value']}  ${resourcelist[0]}            #Instances
   Should Be Equal As Numbers  ${resourceusage[0]['info'][4]['quota_max_value']}  ${resourcelist[1]}            #RAM
   Should Be Equal As Numbers  ${resourceusage[0]['info'][5]['quota_max_value']}  ${resourcelist[2]}            #vCPUs

