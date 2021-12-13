*** Settings ***
Documentation   Flavor creation cancellation
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
#Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - User shall not be able to create a New Flavor with invalid values
    [Documentation]
    ...  Click New Button
    ...  Fill in fields with various invalid values and click save
    ...  Verify proper error is given and Flavor is not added
    [Tags]  passing

    @{table_data_pre}=  Get Table Data
    ${num_pre}=  Get Length  ${table_data_pre}

    Add New Flavor  region=EU  flavor_name=BeepBoop  ram=0  vcpus=-10  disk=9999  decision=test
    Sleep  5

    @{table_data_post}=  Get Table Data
    ${num_post}=  Get Length  ${table_data_post}
    # once again if a flavor is created / deleted the order randomly changes. (bug sent in)
    Should Be Equal  ${num_pre}  ${num_post}


WebUI - User shall be able to Cancel a New Flavor
    [Documentation]
    ...  Click New Button
    ...  Fill in values and click Cancel
    ...  Verify Flavor is not added
    [Tags]  passing

    @{table_data_pre}=  Get Table Data
    ${num_pre}=  Get Length  ${table_data_pre}

    Add New Flavor  region=EU  flavor_name=BeepBoop  ram=0  vcpus=-10  disk=9999  decision=no
    Sleep  5

    @{table_data_post}=  Get Table Data
    ${num_post}=  Get Length  ${table_data_post}

    #Should Be Equal  ${table_data_pre}  ${table_data_post}
    Should Be Equal  ${num_pre}  ${num_post}

*** Keywords ***
Setup
    Log to console        login
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Flavors
