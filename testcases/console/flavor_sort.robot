*** Settings ***
Documentation   Show flavors
Library		      MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections

Suite Setup     Setup
Suite Teardown  Close Browser

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

    Open Flavors
    @{fl}=  Order Flavor Names  5
    @{rowsSorted}=  Get Table Data

    ${num_flavors_listed}=  Get Length  ${rowsSorted}
    ${num_flavors_table}=  Get Length  ${fl}

    ${L1}=  Create List  @{fl}
    ${L2}=  Create List  @{rowsSorted}

    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}
    Lists Should Be Equal  ${L1}  ${L2}

Web UI - user shall be able sort flavors by RAM
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_RAM
    ...  Confirm flavor numerically sorted

    Open Flavors
    @{rows}=  Get Table Data
    @{fl}=  Order Flavor Ram  5

    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}

    ${L1}=  Create List  @{fl}
    ${L2}=  Create List  @{rows}

    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}
    Lists Should Be Equal  ${L1}  ${L2}

Web UI - user shall be able sort flavors by VCPUS
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_vcpus
    ...  Confirm flavor numerically sorted

    Open Flavors
    @{rows}=  Get Table Data
    @{fl}=  Order Flavor Vcpus  5

    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}
    ${L1}=  Create List  @{fl}
    ${L2}=  Create List  @{rows}

    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}
    Lists Should Be Equal  ${L1}  ${L2}


Web UI - user shall be able sort flavors by DISK
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by disk size
    ...  Confirm flavor numerically sorted

    Open Flavors
    @{rows}=  Get Table Data
    @{fl}=  Order Flavor Disk  5
    
    ${num_flavors_listed}=  Get Length  ${fl}
    ${num_flavors_table}=  Get Length  ${rows}
    ${L1}=  Create List  @{fl}
    ${L2}=  Create List  @{rows}

    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}
    Lists Should Be Equal  ${L1}  ${L2}

    Teardown

*** Keywords ***
Setup
    Log to console  login
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}

    Open Compute
    Create Flavor  region=US  flavor_name=andyflavor2  ram=2  disk=2  vcpus=2

Teardown
    Delete Flavor  region=US  flavor_name=andyflavor2  ram=2  disk=2  vcpus=2
    Cleanup Provisioning
