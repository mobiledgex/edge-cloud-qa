*** Settings ***
Documentation   Create Docker based Auto Cluster

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
${len}

*** Test Cases ***
Web UI - User shall be able to create a Docker based Auto Cluster with IpAccessShared
    [Documentation]
    ...  Create a Docker based Auto Cluster with IpAccessShared
    ...  Verify App Instance shows in list
    ...  Delete App Instance

    ${cluster_name}=   Catenate  SEPARATOR=  autocluster  ${app_name}
    Add New App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  type=autocluster  ip_access=Shared  cluster_instance=${cluster_name}  

    ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
    ${time}=  Set Variable  ${appinst_details[0]['data']['created_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Appinst Details
    Log to Console  ${details}
    Should Be Equal   ${details['Created']}   ${timestamp}
    Should Be Equal   ${details['IP Access']}   Shared
    Should Be Equal   ${details['Progress']}   Ready

    Close Details    
            
    MexConsole.Delete App Instance 

    FOR  ${i}  IN RANGE  0  60
        ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
        ${len}=  Get Length  ${appinst_details}
        Exit For Loop If  '${len}' == '0'
        Sleep  2s
    END

    MexMasterController.App Instance Should Not Exist  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}    
    MexConsole.App Instance Should Not Exist

WebUI - User shall be able to create a Docker based Auto Cluster with IpAccessDedicated
    [Documentation]
    ...  Create a Docker based Auto Cluster with IpAccessDedicated
    ...  Verify App Instance shows in list
    ...  Delete App Instance

    ${cluster_name}=   Catenate  SEPARATOR=  autocluster  ${app_name}
    Add New App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  type=autocluster  ip_access=Dedicated  cluster_instance=${cluster_name}

    ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
    ${time}=  Set Variable  ${appinst_details[0]['data']['created_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Appinst Details
    Log to Console  ${details}
    Should Be Equal   ${details['Created']}   ${timestamp}
    Should Be Equal   ${details['IP Access']}   Dedicated
    Should Be Equal   ${details['Progress']}   Ready

    Close Details

    MexConsole.Delete App Instance

    FOR  ${i}  IN RANGE  0  60
        ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
        ${len}=  Get Length  ${appinst_details}
        Exit For Loop If  '${len}' == '0'
        Sleep  2s
    END

    MexMasterController.App Instance Should Not Exist  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
    MexConsole.App Instance Should Not Exist

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser} 
    Open Compute
    Open App Instances

Teardown
    Close Browser
    Cleanup Provisioning
