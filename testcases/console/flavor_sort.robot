*** Settings ***
Documentation   Show flavors
Library		      MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
Web UI - user shall be able sort flavors by name
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_name
    ...  Confirm flavor alphabetically sorted
    # need to add some flavor on US region so we can be sure some exist when we run it. can do this in setup

    Open Flavors
    # this checks if flavor table headings exist

    @{rows}=  Get Table Data

    #@{sorted}= Order Flavor Names
    Order Flavor Names
    ${num_flavors_listed}= Get Length  ${ft)}
    ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}


*** Keywords ***
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
