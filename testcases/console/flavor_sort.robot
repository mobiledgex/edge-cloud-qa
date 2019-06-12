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
    @{ws_asc}=  Get Table Data

    ${num_flavors_table}=  Get Length  ${ws_asc}
    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}

    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    # @{rowsUS}  == ${num_flavors_US}  ||  @{rowsEU} == ${num_flavors_EU}
    &{dictShowFlavors}=  Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  set to dictionary  ${dictShowFlavors}  ${rowsUS}[${i}][data][key][name]  ${rowsUS}[${i}]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  set to dictionary  ${dictShowFlavors}  ${rowsEU}[${i}][data][key][name]  ${rowsEU}[${i}]

    ${sortedDictShowFlavors}=  Get Dictionary Items  ${dictShowFlavors}

    ${ForLoop}=  Get Length  ${dictShowFlavors}
    # this math might change: depending where the name is
    Log To Console  Repeating Ascending Sorted Lists
    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${o} * 2
    \  Log To Console   ${sortedDictShowFlavors}[${o}]
    #\  Log To Console   ${ws_asc}[${i}][1]
    \  Should Be Equal  ${sortedDictShowFlavors}[${o}]  ${ws_asc}[${i}][1]

    #
    # Sort Descending Flavor Names
    #
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_name  sort_order=descending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_name  sort_order=descending

    # Orders table descending
    @{sorting_flavors_Controller}=  Order Flavor Names  1
    # check that this number is DESCENDING now
    @{ws_asc}=  Get Table Data

    ${num_flavors_table}=  Get Length  ${ws_asc}
    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    &{dictShowFlavors}=  Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  set to dictionary  ${dictShowFlavors}  ${rowsUS}[${i}][data][key][name]  ${rowsUS}[${i}]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  set to dictionary  ${dictShowFlavors}  ${rowsEU}[${i}][data][key][name]  ${rowsEU}[${i}]

    # This here returns sorted.
    ${sortedDictShowFlavors}=  Get Dictionary Items  ${dictShowFlavors}
    # Reverse list to have descending order
    Reverse List  ${sortedDictShowFlavors}

    ${ForLoop}=  Get Length  ${dictShowFlavors}
    Log To Console  Repeating Descending Sorted Lists
    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${o} * 2
    \  Log To Console   ${sortedDictShowFlavors}[${o}][data][key][name]
    #\  Log To Console   ${ws_asc}[${i}][1]
    \  Should Be Equal  ${sortedDictShowFlavors}[${o}][data][key][name]  ${ws_asc}[${i}][1]


Web UI - user shall be able sort flavors by RAM
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_RAM
    ...  Confirm flavor numerically sorted

    Open Flavors

    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_ram  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_ram  sort_order=ascending

    @{fl}=  Order Flavor Ram  5
    ${ws_ram_sort}=  Get Table Data
    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_ws}=  Get Length  ${ws_ram_sort}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_ws}  ${num_flavors_listed}

    ${listShowFlavors}=  Create List
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsUS}[${i}][data][ram]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${i}+${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsEU}[${i}][data][ram]
    # Append to List because dictionary overwrites same key

    Sort List  ${listShowFlavors}
    ${ForLoop}=  Get Length  ${listShowFlavors}

    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${finalInt}=  Set Variable  ${i}
    \  Log To Console   ${listShowFlavors}[${i}]
    #\  Log To Console   ${ws_ram_sort}[${i}][2]
    \  ${finalInt}=  Convert To Integer  ${ws_ram_sort}[${i}][2]
    \  Should Be Equal  ${listShowFlavors}[${i}]  ${finalInt}


    #
    # Sort Descending RAM values
    #
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_ram  sort_order=descending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_ram  sort_order=descending

    # Orders table descending
    @{sorting_flavors_Controller}=  Order Flavor Ram  1
    # check that this number is DESCENDING now
    @{ws_asc}=  Get Table Data

    ${num_flavors_table}=  Get Length  ${ws_asc}
    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    ${listShowFlavors}=  Create List
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsUS}[${i}][data][ram]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${i}+${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsEU}[${i}][data][ram]
    # Append to List because dictionary overwrites same key


    Sort List  ${listShowFlavors}
    # Reverse list to have descending order
    Reverse List  ${listShowFlavors}
    ${ForLoop}=  Get Length  ${listShowFlavors}

    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${finalInt}=  Set Variable  ${i}
    \  Log To Console   ${listShowFlavors}[${i}]
    #\  Log To Console   ${ws_asc}[${i}][2]
    \  ${finalInt}=  Convert To Integer  ${ws_asc}[${i}][2]
    \  Should Be Equal  ${listShowFlavors}[${i}]  ${finalInt}


Web UI - user shall be able sort flavors by VCPUS
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by flavor_vcpus
    ...  Confirm flavor numerically sorted

    Open Flavors

    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_vcpus  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_vcpus  sort_order=ascending

    @{fl}=  Order Flavor Vcpus  5
    ${ws_vcpus_sort}=  Get Table Data

    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_ws}=  Get Length  ${ws_vcpus_sort}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_ws}  ${num_flavors_listed}

    ${listShowFlavors}=  Create List
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsUS}[${i}][data][vcpus]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${i}+${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsEU}[${i}][data][vcpus]
    # Append to List because dictionary overwrites same key

    Sort List  ${listShowFlavors}
    ${ForLoop}=  Get Length  ${listShowFlavors}

    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${finalInt}=     Set Variable  ${i}
    \  Log To Console   ${listShowFlavors}[${i}]
    #\  Log To Console   ${ws_vcpus_sort}[${i}][3]
    \  ${finalInt}=     Convert To Integer  ${ws_vcpus_sort}[${i}][3]
    \  Should Be Equal  ${listShowFlavors}[${i}]  ${finalInt}


    #
    # Sort Descending RAM values
    #
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_vcpus  sort_order=descending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_vcpus  sort_order=descending

    # Orders table descending
    @{sorting_flavors_Controller}=  Order Flavor Vcpus  1
    # check that this number is DESCENDING now
    @{ws_asc}=  Get Table Data

    ${num_flavors_table}=  Get Length  ${ws_asc}
    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    ${listShowFlavors}=  Create List
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsUS}[${i}][data][vcpus]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${i}+${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsEU}[${i}][data][vcpus]
    # Append to List because dictionary overwrites same key


    Sort List  ${listShowFlavors}
    # Reverse list to have descending order
    Reverse List  ${listShowFlavors}
    ${ForLoop}=  Get Length  ${listShowFlavors}

    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${finalInt}=     Set Variable  ${i}
    \  Log To Console   ${listShowFlavors}[${i}]
    #\  Log To Console   ${ws_asc}[${i}][3]
    \  ${finalInt}=     Convert To Integer  ${ws_asc}[${i}][3]
    \  Should Be Equal  ${listShowFlavors}[${i}]  ${finalInt}



Web UI - user shall be able sort flavors by DISK
    [Documentation]
    ...  Show flavor name
    ...  Sort flavors by disk size
    ...  Confirm flavor numerically sorted

    Open Flavors

    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_disk  sort_order=ascending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_disk  sort_order=ascending

    @{fl}=  Order Flavor Disk  5
    ${ws_disk_sort}=  Get Table Data

    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_ws}=  Get Length  ${ws_disk_sort}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Log To Console  ____ If this error is thrown then there is an odd mismatch _____
    Should Be Equal  ${num_flavors_ws}  ${num_flavors_listed}

    ${listShowFlavors}=  Create List
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsUS}[${i}][data][disk]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${i}+${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsEU}[${i}][data][disk]
    # Append to List because dictionary overwrites same key

    Sort List  ${listShowFlavors}
    ${ForLoop}=  Get Length  ${listShowFlavors}

    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${finalInt}=     Set Variable  ${i}
    #\  Log To Console   ${listShowFlavors}[${i}]
    \  Log To Console   ${ws_disk_sort}[${i}][4]
    \  ${finalInt}=     Convert To Integer  ${ws_disk_sort}[${i}][4]
    \  Should Be Equal  ${listShowFlavors}[${i}]  ${finalInt}


    #
    # Sort Descending RAM values
    #
    @{rowsEU}=  Show Flavors  region=EU  sort_field=flavor_disk  sort_order=descending
    @{rowsUS}=  Show Flavors  region=US  sort_field=flavor_disk  sort_order=descending

    # Orders table descending
    @{sorting_flavors_Controller}=  Order Flavor Disk  1
    # check that this number is DESCENDING now
    @{ws_asc}=  Get Table Data
    ${num_flavors_table}=  Get Length  ${ws_asc}
    ${num_flavors_US}=  Get Length  ${rowsUS}
    ${num_flavors_EU}=  Get Length  ${rowsEU}
    ${num_flavors_listed}=  Evaluate  ${num_flavors_US}+${num_flavors_EU}
    Should Be Equal  ${num_flavors_listed}  ${num_flavors_table}

    ${listShowFlavors}=  Create List
    :FOR    ${i}    IN RANGE    0    ${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsUS}[${i}][data][disk]

    :FOR    ${i}    IN RANGE    0    ${num_flavors_EU}
    \  ${o}=  Set Variable  ${i}
    \  ${o}=  Evaluate  ${i}+${num_flavors_US}
    \  Append To List  ${listShowFlavors}  ${rowsEU}[${i}][data][disk]
    # Append to List because dictionary overwrites same key


    Sort List  ${listShowFlavors}
    # Reverse list to have descending order
    Reverse List  ${listShowFlavors}
    ${ForLoop}=  Get Length  ${listShowFlavors}

    :FOR    ${i}    IN RANGE    0    ${ForLoop}
    \  ${finalInt}=     Set Variable  ${i}
    \  Log To Console   ${listShowFlavors}[${i}]
    #\  Log To Console   ${ws_asc}[${i}][4]
    \  ${finalInt}=     Convert To Integer  ${ws_asc}[${i}][4]
    \  Should Be Equal  ${listShowFlavors}[${i}]  ${finalInt}



*** Keywords ***
Setup
    Log to console  login
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}

    Open Compute
    Create Flavor  region=US  flavor_name=andyflavor2  ram=2  disk=2  vcpus=2

Teardown
    Cleanup Provisioning
    Close Browser
