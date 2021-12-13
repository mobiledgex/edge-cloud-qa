*** Settings ***
Documentation   Create new cloudlet

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    20 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - user shall be able to put an exiting cloudlet into Maintenance Start Mode
    [Documentation]
    ...  Create a new EU cloudlet
    ...  Update Cloudlet to put the cloudlet into Maintenance Start Mode
    [Tags]  passing

    Open Cloudlets

    Add New Cloudlet  region=EU  physical_name=hawkins  platform_type=Openstack  operator=GDDT  cloudlet_name=${cloudlet_name}

    FOR  ${x}  IN RANGE  0  60
        ${cloudlet_state}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
        Exit For Loop If  '${cloudlet_state[0]['data']['state']}' == '5'
        Sleep  10s
    END

    Change Number Of Rows
    Cloudlet Should Exist

    Search Cloudlet
    MexConsole.Update Cloudlet  maintenance_state=Maintenance Start

    ${cloudlet_details}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
    Should Be Equal As Numbers  ${cloudlet_details[0]['data']['maintenance_state']}  31

    ${time}=  Set Variable  ${cloudlet_details[0]['data']['updated_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Cloudlet Details
    Log to Console  ${details}
    Should Be Equal   ${details['Updated']}   ${timestamp}
    Close Cloudlet Details

    Search Cloudlet
    MexConsole.Delete Cloudlet
    Cloudlet Should Not Exist 

WebUI - user shall be able to put an exiting cloudlet into Maintenance Start No Failover Mode
    [Documentation]
    ...  Create a new EU cloudlet
    ...  Update Cloudlet to put the cloudlet into Maintenance Start No Failover Mode
    [Tags]  passing

    Open Cloudlets

    Add New Cloudlet  region=EU  physical_name=hawkins  platform_type=Openstack  operator=GDDT  cloudlet_name=${cloudlet_name}

    FOR  ${x}  IN RANGE  0  60
        ${cloudlet_state}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
        Exit For Loop If  '${cloudlet_state[0]['data']['state']}' == '5'
        Sleep  10s
    END

    Change Number Of Rows
    Cloudlet Should Exist

    Search Cloudlet
    MexConsole.Update Cloudlet  maintenance_state=Maintenance Start No Failover

    ${cloudlet_details}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
    Should Be Equal As Numbers  ${cloudlet_details[0]['data']['maintenance_state']}  31

    Search Cloudlet
    MexConsole.Delete Cloudlet
    Cloudlet Should Not Exist

WebUI - user shall be able to put an exiting cloudlet from Maintenance Start Mode to Normal Operation Mode
    [Documentation]
    ...  Create a new EU cloudlet
    ...  Update Cloudlet to put the cloudlet from Maintenance Start Mode to Normal Operation Mode
    [Tags]  passing

    Open Cloudlets

    Add New Cloudlet  region=EU  physical_name=hawkins  platform_type=Openstack  operator=GDDT  cloudlet_name=${cloudlet_name}

    FOR  ${x}  IN RANGE  0  60
        ${cloudlet_state}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
        Exit For Loop If  '${cloudlet_state[0]['data']['state']}' == '5'
        Sleep  10s
    END

    Change Number Of Rows
    Cloudlet Should Exist

    Search Cloudlet
    MexConsole.Update Cloudlet  maintenance_state=Maintenance Start

    ${cloudlet_details}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
    Should Be Equal As Numbers  ${cloudlet_details[0]['data']['maintenance_state']}  31

    Search Cloudlet
    MexConsole.Update Cloudlet  maintenance_state=Normal Operation

    ${cloudlet_details}=    Show Cloudlets  region=EU  cloudlet_name=${cloudlet_name}  operator_org_name=GDDT
    Dictionary Should Not Contain Key  ${cloudlet_details[0]['data']}  maintenance_state

    ${time}=  Set Variable  ${cloudlet_details[0]['data']['updated_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Cloudlet Details
    Log to Console  ${details}
    Should Be Equal   ${details['Updated']}   ${timestamp}
    Close Cloudlet Details

    Search Cloudlet
    MexConsole.Delete Cloudlet
    Cloudlet Should Not Exist

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${cloudlet_name}=  Get Default Cloudlet Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Set Suite Variable  ${token}
    Set Suite Variable  ${cloudlet_name}
