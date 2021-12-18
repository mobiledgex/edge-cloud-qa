*** Settings ***
Documentation   Create new App Instance for krakow

Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123
${developer_name}  HackathonTeam-17
${app_name}  japptest1
${app_version}  1.0
${operator}  TMPL
${cloudlet}  krakow-main
${cluster_inst}  VMHackathonTeam-17

## Passes in console.monbiledgex

*** Test Cases ***

Web UI - User shall be able to create a New App Instance for EU Region
    [Documentation]
    ...  Create a new EU App Instance
    ...  Verify App Instance shows in list
    ...  Delete App Instance

    Sleep  5s

    Add New App Instance  region=EU  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}  
    
    App Instance Should Exist  region=EU  org_name=${developer_name}  app_name=${app_name}  version=${app_version}  operator=${operator}  cloudlet=${cloudlet}  cluster_instance=${cluster_inst}

    #sleep  10s

    Delete App Instance  region=EU  developer_name=${developer_name}  app_name=${app_name}  app_version=${app_version}  operator_name=${operator}  cloudlet_name=${cloudlet}  cluster_instance=${cluster_inst}  

    sleep  10s

    App Instance Should Not Exist  region=EU  org_name=${developer_name}  app_name=${app_name}  version=${app_version}  operator=${operator}  cloudlet=${cloudlet}  cluster_instance=${cluster_inst}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open App Instances
Teardown
    Close Browser