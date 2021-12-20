*** Settings ***
Documentation   Show flavors

Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           40 min
# would be good to change these to %{TIMEOUT_TIMER} or something so updating is dynamic

*** Test Cases ***
# ECQ-1530
WebUI - user shall be able to show US flavors
    [Documentation]
    ...  Show US flavors
    ...  Get US flavors from WS
    ...  Verify all flavors exist
    [Tags]  passing

    #MexConsole.Delete Flavor  region=US  flavor_name=flavor1585835687-7166579  ram=1024  disk=1  vcpus=1


    Add New Flavor  region=US
    @{ws}=   Show Flavors  region=US  token=${token}  use_defaults=${False}
    Sleep  5 seconds  # success box is covering the pulldown
    Change Region  US
    ${num_pages}=  Find Number Of Pages
    Flavor Should Exist  change_rows_per_page=True  number_of_pages=${num_pages}
    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log to console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}  number_of_pages=${num_pages}

   ${num_flavors_ws}=     Get Length  ${ws}
   #${num_flavors_table}=  Get Length  ${rows}
   ${num_flavors_table}=  Find Number of Entries
   Should Be Equal  ${num_flavors_ws}  ${num_flavors_table}
   MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off

# ECQ-1531
WebUI - user shall be able to show EU flavors
    [Documentation]
    ...  Show EU flavors
    ...  Get EU flavors from WS
    ...  Verify all flavors exist
    [Tags]  passing

    Add New Flavor  region=EU
    @{ws}=  Show Flavors  region=EU  token=${token}  use_defaults=${False}
    Change Region  EU
    ${num_pages}=  Find Number Of Pages
    Flavor Should Exist  change_rows_per_page=True  number_of_pages=${num_pages}
    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=EU  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}  number_of_pages=${num_pages}

   ${num_flavors_ws}=     Get Length  ${ws}
   #${num_flavors_table}=  Get Length  ${rows}
   ${num_flavors_table}=  Find Number of Entries
   Should Be Equal  ${num_flavors_ws}  ${num_flavors_table}
   MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off

# ECQ-1532
WebUI - user shall be able to show All flavors
    [Documentation]
    ...  Show All flavors
    ...  Get EU and US flavors from WS
    ...  Verify all flavors exist
    [Tags]  passing

    #Add New Flavor  region=EU  flavor_name=flavor.Show.All.Test  ram=2  disk=2  vcpus=2
    Add New Flavor  region=US

    @{wseu}=  Show Flavors  region=EU  token=${token}  use_defaults=${False}
    @{wsus}=  Show Flavors  region=US  token=${token}  use_defaults=${False}

    Open Flavors
    Change Number Of Rows
    ${num_pages}=  Find Number Of Pages
    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{wseu}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=EU  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   : FOR  ${row}  IN  @{wsus}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   ${num_flavors_wsus}=     Get Length  ${wsus}
   ${num_flavors_wseu}=     Get Length  ${wseu}
   ${num_flavors_table}=    Get Length  ${rows}
   ${num_flavors_total}=    Evaluate    ${num_flavors_wsus}+${num_flavors_wseu}

   Should Be Equal    ${num_flavors_total}  ${num_flavors_table}

   MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off
   #MexConsole.Delete Flavor  flavor_name=flavor.Show.All.Test  ram=2  disk=2  vcpus=2


*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Flavors

    ${token}=  Get Supertoken
    Set Suite Variable  ${token}    

Teardown
    #Cleanup Provisioning
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete Flavor
