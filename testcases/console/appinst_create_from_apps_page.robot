*** Settings ***
Documentation   Create new App Instance

Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         DateTime

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    10 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  automation_dev_org
${operator_org_name}  packet
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:11.0
${flavor_name}    automation_api_flavor

*** Test Cases ***
Web UI - User shall be create app instance from apps page
    [Documentation]
    ...  Create an App
    ...  Create an App Instance from apps page

    Add App Instance From Apps Page   region=US  app_name=${app_name}  app_version=1.0  developer_name=${developer_name}  operator_name=packet  cloudlet_name=${cloudlet_name}  deployment_type=kubernetes  cluster_instance=${cluster_inst}  ip_access=Shared
    Open App Instances
   
    ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet_name}
    ${time}=  Set Variable  ${appinst_details[0]['data']['created_at']}
    Log to Console  ${time}

    ${CurrentDate}=  Get Current Date  result_format=%Y-%m-%d
    Log to Console  ${CurrentDate}

    ${details}=  Open Appinst Details  region=US  app_name=${app_name}  app_version=1.0  cluster_name=${cluster_inst}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_org_name}
    Log to Console  ${details}

    Should Be Equal   ${details['Access Type']}   Load Balancer
    Should Be Equal   ${details['Organization']}   ${developer_name}
    Should Be Equal   ${details['Operator']}   ${operator_org_name}
    Should Be Equal   ${details['Flavor']}   ${flavor_name}
    Should Contain   ${details['Created']}   ${CurrentDate}
    Should Be Equal   ${details['Progress']}   Ready

    Close Details

    MexConsole.Delete App Instance   region=US  app_name=${app_name}  app_version=1.0  cluster_instance=${cluster_inst}  cloudlet_name=${cloudlet_name}  operator_name=${operator_org_name}  developer_name=${developer_name}

    FOR  ${i}  IN RANGE  0  5
        ${appinst_details}=   Show App Instances  region=US  app_name=${app_name}  cloudlet_name=${cloudlet_name}
        ${len}=  Get Length  ${appinst_details}
        Exit For Loop If  '${len}' == '0'
        Sleep  2s
    END

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${cloudlet_name}=  Get Default Cloudlet Name
    ${app_name}=  Get Default App Name
    ${cluster_inst}=  Get Default Cluster Name
    Open Browser
    Login to Mex Console  browser=${browser}
    MexMasterController.Create Cloudlet  region=US  operator_org_name=${operator_org_name}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91
    MexMasterController.Create Cluster Instance  region=US  cluster_name=${cluster_inst}  operator_org_name=${operator_org_name}  cloudlet_name=${cloudlet_name}  developer_org_name=${developer_name}  flavor_name=${flavor_name}  ip_access=IpAccessDedicated
    MexMasterController.Create App   region=US  developer_org_name=${developer_name}  image_path=${docker_image}  access_ports=tcp:2015  deployment=kubernetes  image_type=ImageTypeDocker  access_type=loadbalancer  app_name=${app_name}  default_flavor_name=automation_api_flavor
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${cloudlet_name}
    Set Suite Variable  ${cluster_inst}
    Set Suite Variable  ${app_name}

Teardown
    #MexMasterController.Delete App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=1.0  operator_name=${operator_org_name}  cloudlet_name=${cloudlet_name}  cluster_instance=${cluster_inst}
    #MexMasterController.Delete App  region=US  app_name=${app_name}  developer_org_name=${developer_name}
    #MexMasterController.Delete Cloudlet  region=US  operator_org_name=${operator_org_name}  cloudlet_name=${cloudlet_name}
    Cleanup Provisioning
    Close Browser


