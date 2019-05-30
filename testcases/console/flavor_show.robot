*** Settings ***
Documentation   Show flavors

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
Web UI - user shall be able show US flavors
    [Documentation]
    ...  Show US flavors
    ...  Get US flavors from WS
    ...  Verify all flavors exist

    # need to add some flavor on US region so we can be sure some exist when we run it. can do this in setup

    @{ws}=  Show Flavors  region=US
    Log to console  ${ws[0]['data']['key']['name']}	
    Open Flavors

    Change Region  US
	
    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}
	
   ${num_flavors_ws}=     Get Length  ${ws}
   ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_ws}  ${num_flavors_table}

Web UI - user shall be able show EU flavors
    [Documentation]
    ...  Show EU flavors
    ...  Get EU flavors from WS
    ...  Verify all flavors exist

    # need to add some flavor on US region so we can be sure some exist when we run it. can do this in setup

    @{ws}=  Show Flavors  region=EU
    Log to console  ${ws[0]['data']['key']['name']}
    Open Flavors

    Change Region  EU 

    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   ${num_flavors_ws}=     Get Length  ${ws}
   ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_ws}  ${num_flavors_table}

Web UI - user shall be able show All flavors
    [Documentation]
    ...  Show All flavors
    ...  Get EU and US flavors from WS
    ...  Verify all flavors exist

    # need to add some flavor on US and EU region so we can be sure some exist when we run it. can do this in setup

    @{wseu}=  Show Flavors  region=EU
    @{wsus}=  Show Flavors  region=US

    Log to console  ${ws[0]['data']['key']['name']}
    Open Flavors

    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{wseu}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   : FOR  ${row}  IN  @{wsus}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   ${num_flavors_wsus}=     Get Length  ${wsus}
   ${num_flavors_wseu}=     Get Length  ${wseu}

   ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_wsus}+${num_flavors_wseu}  ${num_flavors_table}

*** Keywords ***
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

