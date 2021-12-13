*** Settings ***
Documentation   Click and verify flavor data

Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library          String
Library          Collections

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           20 min

*** Test Cases ***
WebUI - Flavor details should be possible to view
    [Documentation]
    ...  Load Flavors page
    ...  Click a flavor to view details
    ...  Verify flavor details are correct
    [Tags]  passing

    Open Flavors

    @{wsUSEU}=  Show All Flavors  
    ${cnt}=  Get Length  ${wsUSEU}
    ${numbers}=    Evaluate    random.sample(range(0, ${cnt}), 20)    random
    @{L1}=  Create List
    FOR  ${index}  IN  @{numbers}
       Append To List   ${L1}  ${wsUSEU}[${index}]
    END

#    @{ws_us}=   Show Flavors  region=US  sort_field=flavor_name  sort_order=ascending
#    @{ws_eu}=   Show Flavors  region=EU  sort_field=flavor_name  sort_order=ascending

    #update for bug 1406

    : FOR   ${row}   IN   @{L1}
    \  Log To Console   ${row}[data][key][name]
    \  ${details_us}=  Open Flavor Details  flavor_name=${row}[data][key][name]  region=${row}[data][region]

    \  Should Be Equal                     ${details_us}[Region]           ${row}[data][region] 
    \  Should Be Equal                     ${details_us}[Flavor Name]      ${row}[data][key][name]
    \  Should Be Equal As Numbers          ${details_us}[RAM Size(MB)]         ${row}[data][ram]
    \  Should Be Equal As Numbers          ${details_us}[Number of vCPUs]  ${row}[data][vcpus]
    \  Should Be Equal As Numbers          ${details_us}[Disk Space(GB)]       ${row}[data][disk]

#    \  Should Be Equal                     ${details_us}[Number of GPUs]       ${row}[data][disk]


    \  Close Flavor Details

#    : FOR   ${row}   IN   @{ws_eu}
#    \  Log To Console   ${row}[data][key][name]
#    \  ${details_eu}=  Open Flavor Details  flavor_name=${row}[data][key][name]  region=EU
#
#    \  Should Be Equal                     ${details_eu}[Region]           EU
#    \  Should Be Equal                     ${details_eu}[Flavor Name]      ${row}[data][key][name]
#    \  Should Be Equal As Numbers          ${details_eu}[RAM Size(MB)]         ${row}[data][ram]
#    \  Should Be Equal As Numbers          ${details_eu}[Number of vCPUs]  ${row}[data][vcpus]
#    \  Should Be Equal As Numbers          ${details_eu}[Disk Space(GB)]       ${row}[data][disk]
#
##    \  Should Be Equal                     ${details_eu}[Number of GPUs]       ${row}[data][disk]
#
#    \  Close Flavor Details


*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
