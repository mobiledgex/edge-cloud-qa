*** Settings ***
Documentation   Refresh cloudlets

Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - user shall be to refresh Cloudlets 
    [Documentation]
    ...  Load cloudlets page
    ...  Create cloudlet on MexMasterController
    ...  Refresh page and ensure cloudlet exists
    [Tags]  passing

    ${epoch_time}=   Get Time  epoch
    ${cloudlet_name}=  Catenate  SEPARATOR=  cloudlet  ${epoch_time}

    ${epochstring}=  Convert To String  ${epoch_time}
    ${portnum}=    Evaluate    random.randint(49152, 65500)   random
    ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

    #Cloudlet Should Not Exist  region=US  cloudlet_name=${cloudlet_name}  operator_name=dmuus 

    MexMasterController.Create Cloudlet  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=dmuus  latitude=3  longitude=3  number_dynamic_ips=254  ip_support=IpSupportDynamic  platform_type=PlatformTypeFake  #notify_server_address=${port} 
    #@{ws}=  Get Table Data

    Change Number Of Rows
    Refresh Page
    Cloudlet Should Exist  region=US  cloudlet_name=${cloudlet_name}  operator_name=dmuus  state=5 
    #@{ws2}=  Get Table Data

    #Should Not Be Equal  ${ws}  ${ws2}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Cloudlets 

Teardown
    Cleanup Provisioning
    Close Browser
