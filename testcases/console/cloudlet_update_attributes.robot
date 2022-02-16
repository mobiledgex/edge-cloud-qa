*** Settings ***
Documentation   Create new cloudlet

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    20 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - user shall be able to change latitude and longitude of an existing cloudlet
    [Documentation]
    ...  Create a new cloudlet
    ...  Update Cloudlet to change the latitude and longitude
    [Tags]  passing

    Open Cloudlets

    Search Cloudlet  cloudlet_name=${cloudlet_name}
    MexConsole.Update Cloudlet  region=US  cloudlet_name=${cloudlet_name}  operator=packet  latitude=37  longitude=-119

    ${cloudlet_details}=    Show Cloudlets  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=packet
    Should Be Equal As Numbers  ${cloudlet_details[0]['data']['location']['latitude']}  37
    Should Be Equal As Numbers  ${cloudlet_details[0]['data']['location']['longitude']}  -119

    ${CurrentDate}=  Get Current Date  result_format=%Y-%m-%d
    Log to Console  ${CurrentDate}


    ${details}=  Open Cloudlet Details  region=US  cloudlet_name=${cloudlet_name}
    Log to Console  ${details}
    Should Contain   ${details['Updated']}   ${CurrentDate}
    Should Contain   ${details['Cloudlet Location']}   "latitude": 37
    Should Contain   ${details['Cloudlet Location']}   "longitude": -119

    Close Cloudlet Details

WebUI - user shall be able to change number of dynamic IPs of an existing cloudlet
    [Documentation]
    ...  Create a new cloudlet
    ...  Update Cloudlet to change the number of dynamic IPs
    [Tags]  passing

    Open Cloudlets

    Search Cloudlet  cloudlet_name=${cloudlet_name}
    MexConsole.Update Cloudlet  region=US  cloudlet_name=${cloudlet_name}  operator=packet  number_dynamic_ips=250

    ${cloudlet_details}=    Show Cloudlets  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=packet  number_dynamic_ips=250
    Should Be Equal As Numbers  ${cloudlet_details[0]['data']['num_dynamic_ips']}  250

    ${CurrentDate}=  Get Current Date  result_format=%Y-%m-%d
    Log to Console  ${CurrentDate}

    ${details}=  Open Cloudlet Details  region=US  cloudlet_name=${cloudlet_name}
    Log to Console  ${details}
    Should Contain   ${details['Updated']}   ${CurrentDate}
    Should Be Equal as Numbers   ${details['Number of Dynamic IPs']}   250
    Close Cloudlet Details

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${cloudlet_name}=  Get Default Cloudlet Name
    Open Browser
    Login to Mex Console  browser=${browser}
    MexMasterController.Create Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91 
    Open Compute
    Set Suite Variable  ${token}
    Set Suite Variable  ${cloudlet_name}

Teardown
    Cleanup Provisioning
    Close Browser
