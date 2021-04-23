*** Settings ***
Documentation   Create Dedicated Docker Reservable Cluster and verify cloudlet getresourceusage

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Timeout    ${test_timeout_crm}

Suite Setup      Setup
Suite Teardown   Teardown

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationDusseldorfCloudlet
${operator_name_openstack}  TDG
${region}      EU
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:9.0
${developer_org_name_automation}   automation_dev_org

*** Test Cases ***
Controller displays resources consumed/freed by creation/deletion of an autoprovisioned app instance
   [Documentation]
    ...  Create an auto provisioning policy
    ...  Create a docker app and map the policy
    ...  Controller displays the resources consumed by the reservable cluster
    ...  Update App to remove the auto prov policy
    ...  Controller displays correct resource usage after deletion of reservable cluster

   [Tags]  ReservableCluster

   Log to Console  Create Auto Provisioning Policy

   &{cloudlet1}=  Create dictionary  name=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}
   @{cloudletlist}=  Create list  ${cloudlet1}

   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  developer_org_name=${developer_org_name_automation}  token=${user_token}  cloudlet_list=${cloudletlist}

   Log to Console   ${policy_return}

   @{policy_list}=  Create List  ${policy_name}

   ${resourceusage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_dedicated}  token=${super_token}
   #${current_disk_usage}=  Set Variable  ${resourceusage[0]['info'][0]['value']}
   ${current_instances}=  Set Variable  ${resourceusage[0]['info'][3]['value']}
   ${current_ram_usage}=  Set Variable  ${resourceusage[0]['info'][4]['value']}
   ${current_vcpu_usage}=  Set Variable  ${resourceusage[0]['info'][5]['value']}
   #${expected_disk_usage}=  Evaluate  ${current_disk_usage} + 60
   ${expected_instances}=  Evaluate  ${current_instances} + 2
   ${expected_ram_usage}=  Evaluate  ${current_ram_usage} + 6144
   ${expected_vcpu_usage}=  Evaluate  ${current_vcpu_usage} + 4

   Log to Console  Creating App and App Instance
   Create App  region=${region}  app_name=${app_name}  deployment=docker  developer_org_name=${developer_org_name_automation}  auto_prov_policies=@{policy_list}  access_ports=tcp:2015  default_flavor_name=${default_flavor_name}  token=${user_token}
   Sleep  1 min
   Wait For App Instance To Be Ready   region=${region}  developer_org_name=${developer_org_name_automation}  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token} 

   ${appInst}=  Show App Instances  region=${region}   developer_org_name=${developer_org_name_automation}  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}
   ${reservable_cluster_name}=  Set Variable  ${appInst[0]['data']['real_cluster_name']}
   Set Suite Variable  ${reservable_cluster_name}

   Verify Resource Usage  ${expected_instances}  ${expected_ram_usage}  ${expected_vcpu_usage}
   Update Settings  region=${region}  cleanup_reservable_auto_cluster_idletime=1m  token=${super_token}
   Update App  region=${region}  app_name=${app_name}  developer_org_name=${developer_org_name_automation}  auto_prov_policies=@{EMPTY}  token=${user_token}
   Wait For App Instance To Be Deleted  app_name=${app_name}  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_openstack_dedicated}  token=${user_token}
   Sleep  1 min
   Wait For Cluster Instance To Be Deleted  region=${region}  cluster_name=${reservable_cluster_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  token=${super_token}
   Verify Resource Usage  ${current_instances}  ${current_ram_usage}  ${current_vcpu_usage}

*** Keywords ***
Setup
    ${cluster_name}=  Get Default Cluster Name
    ${policy_name}=  Get Default AutoProv Policy Name
    ${app_name}=  Get Default App Name
    ${super_token}=  Get Super Token

    ${user_token}=  Login  username=dev_manager_automation  password=${dev_manager_password_automation}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${user_token}
    Set Suite Variable  ${policy_name}
    Set Suite Variable  ${cluster_name}
    Set Suite Variable  ${app_name}

Verify Resource Usage
   [Arguments]  ${instances}  ${ram}  ${vcpu} 

   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_dedicated}  token=${super_token}
   log to console  ${resource_usage}

   #Should Be Equal As Numbers  ${resource_usage[0]['info'][0]['value']}  ${disk}            #Disk
   Should Be Equal As Numbers  ${resource_usage[0]['info'][3]['value']}  ${instances}       #Instances
   Should Be Equal As Numbers  ${resource_usage[0]['info'][4]['value']}  ${ram}             #RAM
   Should Be Equal As Numbers  ${resource_usage[0]['info'][5]['value']}  ${vcpu}            #vCPUs

Teardown
   Update Settings  region=${region}  cleanup_reservable_auto_cluster_idletime=30m  token=${super_token} 
   Cleanup Provisioning 
