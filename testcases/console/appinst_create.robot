*** Settings ***
Documentation   Create new App Instance

Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  automation_dev_org
${app_name}  automation_api_app
${app_version}  1.0
${operator}  dmuus
${cloudlet}  tmocloud-1
${cluster_inst}  jayacluster

*** Test Cases ***
#ONLY US REGION WORKS

Web UI - User shall be able to create a New App Instance for EU Region
    #[Documentation]
    #...  Create a new EU App Instance
    #...  Verify App Instance shows in list
    #...  Delete App Instance

    #Sleep  5s

    Add New App Instance  region=EU  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}  
    
    App Instance Should Exist  region=EU  org_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}

    Delete App Instance  region=EU  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}  

    App Instance Should Not Exist  region=EU  org_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}

WebUI - User shall be able to create a New App Instance for US Region
    [Documentation]
    ...  Create a new US App Instance
    ...  Verify App Instance shows in list
    ...  Delete App Instance
    [Tags]  passing

    #Sleep  5s
    Add New App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}

    MexConsole.App Instance Should Exist  region=US  org_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}

    MexConsole.Delete App Instance  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}

    sleep  10s
    
    MexConsole.App Instance Should Not Exist  region=US  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${cluster_inst}=  Catenate  SEPARATOR=  ${cluster_inst}  ${epoch}
    Set Suite Variable  ${cluster_inst}
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Create Cluster Instance  region=US  cluster_name=${cluster_inst}  operator_org_name=${operator}  cloudlet_name=${cloudlet}  developer_org_name=${developer_name}  flavor_name=automation_api_flavor  ip_access=IpAccessDedicated
    Open App Instances

Teardown
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete Cluster Instance  region=US  developer_org_name=${developer_name}  operator_org_name=${operator}  cloudlet_name=${cloudlet}  cluster_name=${cluster_inst}
    Run Keyword and Ignore Error  MexMasterController.Delete App Instance  region=US  developer_org_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_org_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance_name=${cluster_inst}

    # Commenting this as Cluster instance is deleted in previous step
 #   Cleanup Provisioning
