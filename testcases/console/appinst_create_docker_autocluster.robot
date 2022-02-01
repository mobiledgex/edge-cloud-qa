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
${developer_name}  automation_dev_org
${app_version}  1.0
${operator}  packet
${cloudlet}  packet-qaregression
${len}

*** Test Cases ***
Web UI - User shall be able to create a Docker based Auto Cluster AppInst in US Region
    [Documentation]
    ...  Create a Docker based Auto Cluster App Instance in US Region
    ...  Verify App Instance shows in list
    ...  Delete App Instance

    ${cluster_name}=   Catenate  SEPARATOR=  autocluster  ${app_name}
    Add New App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  type=autocluster

    ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}

    ${details}=  Open Appinst Details  region=US  app_name=${app_name}  app_version=1.0   cluster_name=${cluster_name}  cloudlet_name=${cloudlet}  operator_org_name=${operator}
    Log to Console  ${details}
    Should Be Equal   ${details['Access Type']}   Load Balancer
    Should Be Equal   ${details['Power State']}   Power On
    Should Be Equal   ${details['Cluster Instance']}   ${cluster_name}

    Close Details    
    MexMasterController.Delete App Instance  region=US   app_name=${app_name}  app_version=1.0  operator_org_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance_name=${cluster_name}

    FOR  ${i}  IN RANGE  0  60
        ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}
        ${len}=  Get Length  ${appinst_details}
        Exit For Loop If  '${len}' == '0'
        Sleep  2s
    END

    MexMasterController.App Instance Should Not Exist  region=US  app_name=${app_name}  cloudlet_name=${cloudlet}    
    MexConsole.App Instance Should Not Exist  region=US   app_name=${app_name}  app_version=1.0   cloudlet_name=${cloudlet}  cluster_instance=${cluster_name}

WebUI - User shall be able to create a Docker based Auto Cluster with IpAccessDedicated
    [Documentation]
    ...  Create a Docker based Auto Cluster in US Region
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
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}
    MexMasterController.Create App   region=US  developer_org_name=${developer_name}   access_ports=tcp:2015  deployment=docker  image_type=ImageTypeDocker  access_type=loadbalancer  app_name=${app_name}  default_flavor_name=m4.small
    Open Compute
    Open App Instances
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
    Cleanup Provisioning
