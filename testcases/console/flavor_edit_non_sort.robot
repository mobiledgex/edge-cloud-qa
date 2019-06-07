*** Settings ***
Documentation   Show flavors
Library		      MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    20 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
#can't sort flavors by edit. and Also can't EDIT a flavor (greyed out)
Web UI - user shall NOT be able to sort flavors by Edit
    [Documentation]
    ...  Click edit header multiple times
    ...  Verify not sorted

    Open Flavors

    @{rows}=  Get Table Data
    Log To Console  Clicking Edit "sort" Button
    Order Flavor Edit
    @{identical}=  Get Table Data
    Lists Should Be Equal  ${rows}  ${identical}

# Question about whether the edit button should exist or just wait until support enables
# Web UI - user shall NOT be able to Edit flavors
#    [Documentation]
#    ...  Verify that nothing occurs when clicking 'disabled_role' button "edit"
#
#    Open Flavors
#
#    @{rows}=  Get Table Data
#
#    Flavor Edit Fail
#    @{rows1.0}=  Get Table Data
#    # Nothing should have changed
#    Lists Should Be Equal  ${rows}  ${rows1.0}

*** Keywords ***
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
