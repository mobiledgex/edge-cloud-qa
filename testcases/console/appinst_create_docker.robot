*** Settings ***
Documentation   Create new App Instance

Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         DateTime
	
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX
${app_name}  docker-automation-app
${app_version}  1.0
${operator}  packet
${cloudlet}  packet-qaregression
${cluster_name}  testwebuicluster

*** Test Cases ***
Web UI - User shall be able to create a Docker based App Instance
    [Documentation]
    ...  Create a Docker based Cluster Instance with IpAccessShared
    ...  Create App Instance
    ...  Verify App Instance shows in list
    ...  Delete App Instance

    Add New App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_name}  

    ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
    ${time}=  Set Variable  ${appinst_details[0]['data']['created_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Appinst Details
    Log to Console  ${details}
    Should Be Equal   ${details['Created']}   ${timestamp}
    Should Be Equal   ${details['Progress']}   Ready

    Close Details    
            
    MexMasterController.Delete App Instance  region=US  app_name=${app_name}  app_version=${app_version}  cloudlet_name=${cloudlet}  operator_org_name=${operator}  developer_org_name=${developer_name}  cluster_instance_name=${cluster_name}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser} 
    Open Compute
    Create Cluster Instance  region=US  cluster_name=${cluster_name}  operator_org_name=${operator}  cloudlet_name=${cloudlet}  developer_org_name=${developer_name}  flavor_name=automation_api_flavor  ip_access=IpAccessShared  deployment=docker
    Open App Instances

Teardown
    Close Browser
    Cleanup Provisioning
