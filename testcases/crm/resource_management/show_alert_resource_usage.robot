*** Settings ***
Documentation  CloudletResourceUsage Alerts

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexOpenstack  environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV} 
Library  MexApp
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout    ${test_timeout_crm1}

*** Variables ***
${region}=  EU
${developer}=  mobiledgex

${operator_name_openstack}  GDDT
${physical_name_openstack}  sunnydale

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:9.0
${qcow_centos_image}  https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:8d8f9c268fd419b16084c9ba054b483a
${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3326
Alerts are triggered when alert threshold for cloudlet/infra resource limits are exceeded
   [Documentation]
   ...  - Create Cloudlet with resource quotas and non default alert_thresholds
   ...  - Verify default_resource_alert_threshold
   ...  - Verify infra limits from output of cloudletinfo show
   ...  - Verify current resource usage and infra limits from output of getresourceusage
   ...  - Verify alerts are triggered when alert_threshold for cloudlet resource limits are exceeded
   ...  - Verify alerts are triggered when alert threshold for infra limits are exceeded
   ...  - Verify alerts are removed after Update Cloudlet to increase resource quotas
   ...  - Verify alerts are removed after cloudlet is deleted

   &{resource1}=  Create Dictionary  name=RAM  value=14336  alert_threshold=75
   &{resource2}=  Create Dictionary  name=vCPUs  value=8    alert_threshold=80
   &{resource3}=  Create Dictionary  name=Instances  value=4  alert_threshold=90
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}


   # create cloudlet with resource quotas
   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  resource_list=${resource_list}  token=${tokenop}  auto_delete=False

   Should Be Equal As Numbers   ${cloudlet1['data']['default_resource_alert_threshold']}  80

   Verify Resource Usage  2  8192  4  CurrentUsage
   Verify Resource Usage  4  14336  8  MaxQuota
  
   ${cloudlet_info}=   Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}  token=${tokenop}

   ${openstack_limits}=  Get Limits
   Log to Console  ${openstack_limits}
   
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][0]['value']}              ${openstack_limits['totalRAMUsed']}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][0]['infra_max_value']}    ${openstack_limits['maxTotalRAMSize']}

   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][1]['value']}              ${openstack_limits['totalCoresUsed']}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][1]['infra_max_value']}    ${openstack_limits['maxTotalCores']}

   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][2]['value']}              ${openstack_limits['totalGigabytesUsed']}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][2]['infra_max_value']}    ${openstack_limits['maxTotalVolumeGigabytes']}

   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][3]['value']}              ${openstack_limits['totalInstancesUsed']}
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['info'][3]['infra_max_value']}    ${openstack_limits['maxTotalInstances']}


   ${ram_inframaxvalue}=    Set Variable  ${cloudlet_info[0]['data']['resources_snapshot']['info'][0]['infra_max_value']}
   ${cores_inframaxvalue}=  Set Variable  ${cloudlet_info[0]['data']['resources_snapshot']['info'][1]['infra_max_value']}
   ${disk_inframaxvalue}=   Set Variable  ${cloudlet_info[0]['data']['resources_snapshot']['info'][2]['infra_max_value']}
   ${inst_inframaxvalue}=   Set Variable  ${cloudlet_info[0]['data']['resources_snapshot']['info'][3]['infra_max_value']}

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  token=${tokendev}  auto_delete=False
   Verify Resource Usage   4  14336  8  CurrentUsage
   Verify Resource Usage   ${inst_inframaxvalue}  ${ram_inframaxvalue}  ${cores_inframaxvalue}  MaxInfra 

   Sleep  60s

   #Verify Soft Alert
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 75% of RAM is used  token=${tokenop}
   Should Not Be Empty  ${alert1[0]['data']}

   ${alert2}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 80% of vCPUs is used  token=${tokenop}
   Should Not Be Empty  ${alert2[0]['data']}

   #${alert3}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 85% of Disk is used  token=${tokenop}
   #Should Not Be Empty  ${alert3[0]['data']}

   ${alert4}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 90% of Instances is used  token=${tokenop}
   Should Not Be Empty  ${alert4[0]['data']}

   &{resource1}=  Create Dictionary  name=RAM  value=28672  alert_threshold=75
   &{resource2}=  Create Dictionary  name=vCPUs  value=16    alert_threshold=80
   &{resource3}=  Create Dictionary  name=Instances  value=8  alert_threshold=90
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}

   # update cloudlet with resource quotas
   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}

   Sleep  60s
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 75% of RAM is used  token=${tokenop}
   Should Be Empty  ${alert1}

   ${alert2}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 80% of vCPUs is used  token=${tokenop}
   Should Be Empty  ${alert2}

   #${alert3}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 85% of Disk is used  token=${tokenop}
   #Should Be Empty  ${alert3}

   ${alert4}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 90% of Instances is used  token=${tokenop}
   Should Be Empty  ${alert4}

   ${openstack_limits}=  Get Limits
   ${ram_infra_usage}=  Evaluate  ${openstack_limits['totalRAMUsed']}/${openstack_limits['maxTotalRAMSize']} * 100
   ${vcpu_infra_usage}=  Evaluate  ${openstack_limits['totalCoresUsed']}/${openstack_limits['maxTotalCores']} * 100
   #${disk_infra_usage}=  Evaluate  ${openstack_limits['totalGigabytesUsed']}/${openstack_limits['maxTotalVolumeGigabytes']} * 100
   ${instances_infra_usage}=  Evaluate  ${openstack_limits['totalInstancesUsed']}/${openstack_limits['maxTotalInstances']} * 100
   ${ram_alert_threshold}=  Evaluate  ${ram_infra_usage} - 1
   ${vcpu_alert_threshold}=  Evaluate  ${vcpu_infra_usage} - 1
   #${disk_alert_threshold}=  Evaluate  ${disk_infra_usage} - 1
   ${instances_alert_threshold}=  Evaluate  ${instances_infra_usage} - 1

   &{resource1}=  Create Dictionary  name=RAM  value=28672  alert_threshold=${ram_alert_threshold}
   &{resource2}=  Create Dictionary  name=vCPUs  value=16    alert_threshold=${vcpu_alert_threshold}
   #&{resource3}=  Create Dictionary  name=Disk  value=280   alert_threshold=${disk_alert_threshold}
   &{resource3}=  Create Dictionary  name=Instances  value=8  alert_threshold=${instances_alert_threshold}
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}

   # update cloudlet with resource quotas
   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}

   ${ram_alert_threshold}=  Set Variable  ${cloudlet1['data']['resource_quotas'][0]['alert_threshold']}
   ${vcpu_alert_threshold}=  Set Variable  ${cloudlet1['data']['resource_quotas'][1]['alert_threshold']}
   #${disk_alert_threshold}=  Set Variable  ${cloudlet1['data']['resource_quotas'][2]['alert_threshold']}
   ${instances_alert_threshold}=  Set Variable  ${cloudlet1['data']['resource_quotas'][2]['alert_threshold']}

   Sleep  60s

   #Verify Infra Alert
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=[Infra] More than ${ram_alert_threshold}% of RAM is used  token=${tokenop}
   Should Not Be Empty  ${alert1[0]['data']}

   ${alert2}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=[Infra] More than ${vcpu_alert_threshold}% of vCPUs is used  token=${tokenop}
   Should Not Be Empty  ${alert2[0]['data']}

   #${alert3}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=[Infra] More than ${disk_alert_threshold}% of Disk is used  token=${tokenop}
   #Should Not Be Empty  ${alert3[0]['data']}

   ${alert4}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=[Infra] More than ${instances_alert_threshold}% of Instances is used  token=${tokenop}
   Should Not Be Empty  ${alert4[0]['data']}

   #Alerts should be removed after cloudlet is deleted
   Delete Cluster Instance  region=${region}  developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${tokendev}
   Delete Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   Sleep  10s
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   Should Be Empty  ${alert1}
 
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

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorManager  
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
   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${tokenop}
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

