*** Settings ***
Documentation   Create new flavor

Library		MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min
${region}  US

*** Test Cases ***
WebUI - user shall be able to create a new EU flavor
    [Documentation]
    ...  Create a new flavor
    ...  Fill in Region=US and all proper values
    ...  Verify flavor shows in list
    [Tags]  passing

    Get Table Data
    Add New Flavor  region=EU  flavor_name=${flavor_name_default}

    Flavor Should Exist  flavor_name=${flavor_name_default}  change_rows_per_page=True  number_of_pages=${num_pages}
    # should also call the WS to check the flavor
    MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off
    Flavor Should Not Exist  flavor_name=${flavor_name_default}

WebUI - user shall be able to create a new US flavor with GPU
    [Documentation]
    ...  Click New button
    ...  Fill in Region=US and all proper values with GPU
    ...  Verify Flavor is created and list is updated
    [Tags]  passing

    Get Table Data
    Add New Flavor  region=US  flavor_name=${flavor_name_default}  ram=2048  vcpus=2  disk=80  gpu=true

    Flavor Should Exist  flavor_name=${flavor_name_default}  change_rows_per_page=True  number_of_pages=${num_pages}  gpu=true
    ${details}=  Open Flavor Details  flavor_name=${flavor_name_default}  region=US
    Log to Console  ${details}
    Should Be Equal                     ${details}[Region]           US
    Should Be Equal                     ${details}[Flavor Name]      ${flavor_name_default}
    Should Be Equal As Numbers          ${details}[RAM Size(MB)]         2048
    Should Be Equal As Numbers          ${details}[Number of vCPUs]  2
    Should Be Equal As Numbers          ${details}[Disk Space(GB)]       80
    Should Contain                      ${details}[GPU]              1
    Close Flavor Details

    # should also call the WS to check the flavor
    MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off
    Flavor Should Not Exist  flavor_name=${flavor_name_default}

*** Keywords ***
Setup
    ${flavor_name_default}=  Get Default Flavor Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Sleep  3s
    Open Flavors
    ${token}=  Get Supertoken
    @{ws1}=  Show Flavors  region=EU  token=${token}  use_defaults=${False} 
    @{ws2}=  Show Flavors  region=US  token=${token}  use_defaults=${False} 
    ${num_orgs_ws1}=     Get Length  ${ws1}
    ${num_orgs_ws2}=     Get Length  ${ws2}
    ${total}=  Evaluate  ${num_orgs_ws1}+${num_orgs_ws2}
    ${result}=  Evaluate  ${total}/75
    ${num_pages}=  Evaluate  math.ceil(${result})  modules=math
    Set Suite Variable  ${token}
    Set Suite Variable  ${num_pages}
    Set Suite Variable  ${flavor_name_default}

Teardown
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete Flavor  region=${region}
