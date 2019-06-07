*** Settings ***
Documentation   Show flavors
Library		      MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections

Suite Setup     Setup
Suite Teardown  Teardown

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
    # Sort Ascending With Both Regions
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_name  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_name  sort_order=ascending

    @{sorting_flavors_Controller}=  Order Flavor Names  5
    @{ws_sorted}=  Get Table Data

    Log To Console  THE ROWS NOT SORTED AGAIN __x_________________----
    Log To Console  ${ws_sorted}
    Log To Console  THE ROWS ___x________----__--__-

    ${num_flavors_table}=  Get Length  ${ws_sorted}
    ${num_flavors_1}=  Get Length  ${rowsUS}
    ${num_flavors_2}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_1}+${num_flavors_2}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    # @{rowsUS}  == ${num_flavors_1}  ||  @{rowsEU} == ${num_flavors_2}
    &{dictShowFlavors}=  Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${num_flavors_1}
    \  set to dictionary  ${dictShowFlavors}  ${rowsUS}[${i}][data][key][name]  ${rowsUS}[${i}]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_2}
    \  set to dictionary  ${dictShowFlavors}  ${rowsEU}[${i}][data][key][name]  ${rowsEU}[${i}]

    ${sortedDictShowFlavors}=  Get Dictionary Items  ${dictShowFlavors}

    ${ForLoop}=  Get Length  ${dictShowFlavors}
    ${ForLoop}=  Evaluate  ${ForLoop} - 1
    # this math might change: depending where the name is
    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${o} * 2
    \  Log To Console   ${sortedDictShowFlavors}[${o}]
    \  Log To Console   ${ws_sorted}[${i}][1]
    \  Should Be Equal  ${sortedDictShowFlavors}[${o}]  ${ws_sorted}[${i}][1]

    #
    # Sort Descending Flavor Names
    #
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_name  sort_order=descending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_name  sort_order=descending

    # Orders table descending
    @{sorting_flavors_Controller}=  Order Flavor Names  1
    # check that this number is DESCENDING now

    @{ws_sorted}=  Get Table Data

    Log To Console  THE ROWSSS ________
    Log To Console  ${rowsEU}
    Log To Console  THE ROWSSS ________
    Log To Console  ${rowsUS}

    ${num_flavors_table}=  Get Length  ${ws_sorted}
    ${num_flavors_1}=  Get Length  ${rowsUS}
    ${num_flavors_2}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_1}+${num_flavors_2}

    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    &{dictShowFlavors}=  Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${num_flavors_1}
    \  set to dictionary  ${dictShowFlavors}  ${rowsUS}[${i}][data][key][name]  ${rowsUS}[${i}]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_2}
    \  set to dictionary  ${dictShowFlavors}  ${rowsEU}[${i}][data][key][name]  ${rowsEU}[${i}]

    # This here returns sorted. I dont want sorted we already have in reverse
    ${sortedDictShowFlavors}=  Get Dictionary Items  ${dictShowFlavors}

    ${ForLoop}=  Get Length  ${dictShowFlavors}
    ${ForLoop}=  Evaluate  ${ForLoop} - 1
    # this math might change: depending where the name is
    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${o} * 2
    \  Log To Console   ${sortedDictShowFlavors}[${o}]
    \  Log To Console   ${ws_sorted}[${i}][1]
    \  Should Be Equal  ${sortedDictShowFlavors}[${o}]  ${ws_sorted}[${i}][1]


Web UI - user shall be able sort flavors by RAM
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_RAM
    ...  Confirm flavor numerically sorted

    Open Flavors
    @{fl}=  Order Flavor Ram  5
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_ram  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_ram  sort_order=ascending
    ${num_flavors_1}=  Get Length  ${rowsUS}
    ${num_flavors_2}=  Get Length  ${rowsEU}
    ${num_flavors_fl}=  Get Length  ${fl}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_1}+${num_flavors_2}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_fl}  ${num_flavors_listed}
    Log To Console  ${fl}
    Log To Console  ${rowsUS}[0]

    &{dictShowFlavors}=  Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${num_flavors_1}
    \  Log To Console  ${i}
    \  set to dictionary  ${dictShowFlavors}  ${rowsUS}[${i}][ram]  ${rowsUS}[${i}]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_2}
    \  set to dictionary  ${dictShowFlavors}  ${rowsEU}[${i}][ram]  ${rowsEU}[${i}]


    ${sortedDictShowFlavors}=  Get Dictionary Items  ${dictShowFlavors}

    ${ForLoop}=  Get Length  ${dictShowFlavors}
    ${ForLoop}=  Evaluate  ${ForLoop} - 1
    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${o} * 2
    \  Log To Console   ${sortedDictShowFlavors}[${o}]
    \  Log To Console   ${fl}[${i}][1]
    \  Should Be Equal  ${sortedDictShowFlavors}[${o}]  ${fl}[${i}][1]


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


*** Keywords ***
Setup
    Log to console  login
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}

    Open Compute
    Create Flavor  region=US  flavor_name=andyflavor2  ram=2  disk=2  vcpus=2

Teardown
    Cleanup Provisioning
    Close Browser
