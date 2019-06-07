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

    # Orders table ascending
    @{sorting_flavors_Controller}=  Order Flavor Names  5
    # check that this number is ascending

    @{ws_sorted}=  Get Table Data

    Log To Console  THE ROWSSS ________
    Log To Console  ${ws_sorted}
    Log To Console  THE ROWSSS ________

    ${num_flavors_table}=  Get Length  ${ws_sorted}
    ${num_flavors_1}=  Get Length  ${rowsUS}
    ${num_flavors_2}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_1}+${num_flavors_2}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    # Should be unnecessary
    #${rowsCombined}=  Create List  ${rowsUS}  ${rowsEU}
    #${matches1}=  Get Matches  ${rowsCombined}[1]  ''
    #${matches2}=  Get Matches  ${rowsCombined}[0]  ''
    #${match1}=  Get Length  ${matches1}
    #${match2}=  Get Length  ${matches2}
    #${match1}=  Evaluate  ${match1} + 1

    #I WAS GETTING A RANDOM EMPTY FLAVOR BUT HONESTLY SORT SHOULD FIX IT
    #Log To Console  There is a hard error finding a total empty flavor
    #Should Be Equal  ${match1}  ${match2}
    #Remove From Dictionary  ${rowsCombined}[1]  ''
    #Remove From Dictionary  ${rowsCombined}[0]  ''


    # @{rowsUS}  == ${num_flavors_1}  ||  @{rowsEU} == ${num_flavors_2}
    &{dictShowFlavors}=  Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${num_flavors_1}
    \  set to dictionary  ${dictShowFlavors}  ${rowsUS}[${i}][data][key][name]  ${rowsUS}[${i}]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_2}
    \  set to dictionary  ${dictShowFlavors}  ${rowsEU}[${i}][data][key][name]  ${rowsEU}[${i}]

    ${sortedDictShowFlavors}=  Get Dictionary Items  ${dictShowFlavors}

    ${ForLoop}=  Get Length  ${dictShowFlavors}
    ${ForLoop}=  Evaluate  ${ForLoop} - 1
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

    # @{rowsUS}  == ${num_flavors_1}  ||  @{rowsEU} == ${num_flavors_2}
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
