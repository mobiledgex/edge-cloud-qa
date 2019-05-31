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

    @{ws}=  Show Flavors
    # to check against name sort funct

    Log to console  ${ws[0]['data']['key']['name']}




    Open Flavors
    # this checks if flavor table headings exist

    Change Region  US
    # THIS RIGHT HERE AH

    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   ${num_flavors_ws}=     Get Length  ${ws}
   ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_ws}  ${num_flavors_table}


   *** Keywords ***
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
