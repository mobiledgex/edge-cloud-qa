*** Settings ***
Documentation   Sorting Accounts

Library		MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections
Library         String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min


*** Test Cases ***
WebUI - Sorting accounts by Username
    [Documentation]
    ...  Open Accounts page
    ...  Check sort functionality of table username headers
    ...  Confirm sort occurs / functions properly

    @{ws_asc}=  Show Accounts  sort_field=username  sort_order=ascending
    Sort Account Name  2
    @{rowsAccounts_asc}=  Get Table Data
    log to console  ${rowsAccounts_asc}
    log to console  =========
    log to console  ${ws_asc}

    ${num_accounts_mcc}=  Get Length  ${ws_asc}
    ${num_accounts_table}=    Get Length  ${rowsAccounts_asc}
    Should Be Equal  ${num_accounts_table}  ${num_accounts_mcc}

    ${counter}=  Set Variable  0
    :FOR    ${row}    IN  @{ws_asc} 
    \  Log to console   ${row}
#    \  Should Be Equal  ${row['Name']}  ${rowsAccounts_asc[${counter}][0]} 
    \  Account Should Match  ${rowsAccounts_asc[${counter}]}  account_name=${row['Name']}  email=${row['Email']}  email_verified=${row['EmailVerified']}  locked=${row['Locked']}
    \  ${counter}=  Evaluate  ${counter} + 1

#    &{dictShowAccounts}=  Create Dictionary
#    :FOR    ${i}    IN RANGE    0    ${num_accounts_table}
#    \  set to dictionary  ${dictShowAccounts}  ${rowsAccounts}[${i}][Name]  ${ws_asc}[${i}][0]

#    ${sortedListShowAccounts}=  Get Dictionary Items  ${dictShowAccounts}
#    ${ForLoop}=  Get Length  ${dictShowAccounts}

#    Log To Console  \nRepeating Ascending Sorted Lists
#    Log To Console   ${sortedListShowAccounts}[1]
#    Should Be Equal  ${sortedListShowAccounts}[1]  ${ws_asc}[0][0]
#    :FOR    ${i}    IN RANGE    1    ${ForLoop}
#    \  ${o}=  Set Variable  ${i}
#    \  ${o}=  Evaluate  ${o} * 2
#    \  Log    ${sortedListShowAccounts}[${o}]
#    \  Log to console   ${ws_asc}[${i}]
#    \  Should Be Equal  ${sortedListShowAccounts}[${o}]  ${ws_asc}[${i}][0]
#    # WHEN THE NEW BUTTON IS FIXED, CHANGE THE MATH

    @{ws_desc}=  Show Accounts  sort_field=username  sort_order=descending
    Sort Account Name  1
    @{rowsAccounts_desc}=  Get Table Data

    ${ForLoop}=    Get Length  ${ws_desc}
    ${CheckLoop}=  Get Length  ${rowsAccounts_desc}
    Should Be Equal  ${CheckLoop}  ${ForLoop}

    Log To Console  \nRepeating Descending Sorted Lists

    # New\n  is 5 char
    #${stringTEMP}=  Get Substring  ${ws_asc}[0][0]  4
    #Should Be Equal  ${rowsAccounts}[0][Name]  ${stringTEMP}
    #Log To Console   ${stringTemp}

    ${counter}=  Set Variable  0
    :FOR    ${row}    IN  @{ws_desc} 
    \  Log to console    ${row}
    \  Account Should Match  ${rowsAccounts_desc[${counter}]}  account_name=${row['Name']}  email=${row['Email']}  email_verified=${row['EmailVerified']}  locked=${row['Locked']}
    \  ${counter}=  Evaluate  ${counter} + 1

WebUI - Sorting accounts by Email
    [Documentation]
    ...  Open Accounts page
    ...  Check sort functionality of table email headers
    ...  Confirm sort occurs / functions properly

    @{ws_asc}=  Show Accounts  sort_field=email  sort_order=ascending

    Sort Account Email  3
    @{rowsAccounts_asc}=  Get Table Data
    ${num_accounts_mcc}=  Get Length  ${ws_asc}
    ${num_accounts_table}=    Get Length  ${rowsAccounts_asc}
    Should Be Equal  ${num_accounts_table}  ${num_accounts_mcc}

    ${counter}=  Set Variable  0
    :FOR    ${row}    IN  @{ws_asc}
    \  Log to console    ${row}
    \  Account Should Match  ${rowsAccounts_asc[${counter}]}  account_name=${row['Name']}  email=${row['Email']}  email_verified=${row['EmailVerified']}  locked=${row['Locked']}
    \  ${counter}=  Evaluate  ${counter} + 1

#    &{dictShowAccounts}=  Create Dictionary
#    :FOR    ${i}    IN RANGE    0    ${num_accounts_table}
#    \  set to dictionary  ${dictShowAccounts}  ${rowsAccounts}[${i}][Email]  ${ws_asc}[${i}][1]
#    ${sortedListShowAccounts}=  Get Dictionary Items  ${dictShowAccounts}
#    ${ForLoop}=  Get Length  ${dictShowAccounts}

#    Log To Console  \nRepeating Ascending Sorted Lists
#    :FOR    ${i}    IN RANGE    0    ${ForLoop}
#    \  ${o}=  Set Variable  ${i}
#    \  ${o}=  Evaluate  ${o} * 2
#    \  Log To Console   ${sortedListShowAccounts}[${o}]
#    \  Should Be Equal  ${sortedListShowAccounts}[${o}]  ${ws_asc}[${i}][1]

#    Reverse List  ${sortedListShowAccounts}
    @{ws_desc}=  Show Accounts  sort_field=email  sort_order=descending

    Sort Account Email  1
    @{rowsAccounts_desc}=  Get Table Data

    ${counter}=  Set Variable  0
    :FOR    ${row}    IN  @{ws_desc}
    \  Log to console    ${row}
    \  Account Should Match  ${rowsAccounts_desc[${counter}]}  account_name=${row['Name']}  email=${row['Email']}  email_verified=${row['EmailVerified']}  locked=${row['Locked']}
    \  ${counter}=  Evaluate  ${counter} + 1

#    ${len}=  Get Length  ${sortedListShowAccounts}
#    @{newListSortedAccounts}=  Create List
#    :FOR    ${i}    IN RANGE    0    ${len}
#    \  ${o}=  Evaluate  ${i}%2
#    \  Run Keyword If  ${o}!=0  Append To List  ${newListSortedAccounts}  ${sortedListShowAccounts}[${i}]

#    Log To Console  \nRepeating Descending Sorted Lists
#    :FOR    ${i}    IN RANGE    0    ${ForLoop}
#    \  Log To Console   ${newListSortedAccounts}[${i}]
#    \  Should Be Equal  ${newListSortedAccounts}[${i}]  ${ws_asc2}[${i}][1]

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute
    Open Accounts

Teardown
    Cleanup Provisioning
    Close Browser
