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
    @{fl}=  Order Flavor Names  5
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_name  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_name  sort_order=ascending

    ${rowsCombined}=  Create List  ${rowsUS}  ${rowsEU}

    ${num_flavors_1}=  Get Length  ${rowsUS}
    ${num_flavors_2}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_1}+${num_flavors_2}
    ${num_flavors_fl}=  Get Length  ${fl}

    ${L1}=  Create List  @{fl}
    ${matches1}=  Get Matches  ${rowsCombined}[1]  ''
    ${matches2}=  Get Matches  ${rowsCombined}[0]  ''
    ${match1}=  Get Length  ${matches1}
    ${match2}=  Get Length  ${matches2}
    # ${match1}=  Evaluate  ${match1} + 1
    # Should be unnecessary

    Log To Console  There is a hard error finding a total empty flavor
    Should Be Equal  ${match1}  ${match2}
    Remove From Dictionary  ${rowsCombined}[1]  ''
    Remove From Dictionary  ${rowsCombined}[0]  ''
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_fl}

    ${num_flavors_fl}=  Evaluate  ${num_flavors_fl} - ${match1}
    Log To Console  THIS IS THE TABLE ______
    Log To Console  HEYYY
    Log To Console  and why not ask EU ONES ________________________________
    Log To Console  ${rowsCombined}[1]
    Log To Console  THEN THE US ONES ________________________________
    Log To Console  ${rowsCombined}[0]

    &{dictTotal}=  Create Dictionary
    #${i}=  ${0}  # ${}
    #  iteration
    #  MY TROUBLE IS THAT I CAN"T COMBINE THE DICTS OF US AND EU.
    # @{rowsEU}  == ${num_flavors_2}
    :FOR    ${i}    IN RANGE    0    ${num_flavors_1}
    \  Log To Console  ${i}
    \  set to dictionary  ${dictTotal}  ${rowsUS}[${i}][data][key][name]  ${rowsUS}[${i}]

    # Now for the EU
    Log To Console  That was the US additions. Check for total? It should be 17...
    :FOR    ${i}    IN RANGE    ${num_flavors_1}    ${num_flavors_2}
    \  Log To Console  ${i}
    \  set to dictionary  ${dictTotal}  ${rowsEU}[${i}][data][key][name]  ${rowsEU}[${i}]

    ${bruh}=  Get Length  ${dictTotal}
    Log To Console  ${num_flavors_1}
    Log To Console  ${num_flavors_2}

    #\  Log To Console  ${rowsCombined}[0][${i}]
    # \  Should Be Equal  ${rowsCombined}[0][${i}][data][key][name]  @{fl}[${i}]

    # Lists Should Be Equal  ${L1}  ${L2}

Web UI - user shall be able sort flavors by RAM
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_RAM
    ...  Confirm flavor numerically sorted

    Open Flavors
    @{rows}=  Get Table Data
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_ram  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_ram  sort_order=ascending

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


*** Keywords ***
Setup
    Log to console  login
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}

    Open Compute
    Create Flavor  region=US  flavor_name=andyflavor2  ram=2  disk=2  vcpus=2

Teardown
    Cleanup Provisioning
    Close Browser
