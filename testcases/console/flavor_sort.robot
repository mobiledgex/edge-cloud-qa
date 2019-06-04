*** Settings ***
Documentation   Show flavors
Library		      MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections

Suite Setup      Setup
Suite Teardown   Close Browser

Test Timeout    20 minutes

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
    # need to add some flavor so we can be sure some exist when we run it. can do this in setup

    Open Flavors
    #@{rows}=  Get Table Data
    @{rows}=  Order Flavor Names  3
    @{fl}=  Order Flavor Names  5


    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}

    ${L1}=  Create List  @{fl}
    # This list remains sorted by python, second one is sorted by framework to check 2 sorts.
    ${L2}=  Create List  @{rows}
    ${L3}=  Sort List  ${L2}

   Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}
   Lists Should Be Equal  ${L1}  ${L2}


Web UI - user shall be able sort flavors by RAM
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_RAM
    ...  Confirm flavor numerically sorted

    Open Flavors

    @{rows}=  Get Table Data

    @{fl}=  Order Flavor Ram
    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}


Web UI - user shall be able sort flavors by VCPUS
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_vcpus
    ...  Confirm flavor numerically sorted

    Open Flavors

    @{rows}=  Get Table Data

    @{fl}=  Order Flavor Vcpus
    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}


Web UI - user shall be able sort flavors by DISK
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by disk size
    ...  Confirm flavor numerically sorted

    Open Flavors

    @{rows}=  Get Table Data

    @{fl}=  Order Flavor Disk
    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

*** Keywords ***
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    # ADD flavors
    Open Compute
