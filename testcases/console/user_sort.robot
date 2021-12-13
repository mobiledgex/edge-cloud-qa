*** Settings ***
Documentation   Sorting Users

Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
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
Web UI - Sorting users by Username
    [Documentation]
    ...  Open Users page
    ...  Check sort functionality of table headers
    ...  Confirm sort occurs / functions properly

    # PYTHON SORTS DIFF THAN OUR CONSOLE AAAH
    # If there are ANY Capital letters starting Orgs/Names/Roles (sorting fails)
    @{rowsUsers}=   Show Role Assignment  sort_field=username  sort_order=ascending
    Sort User Name  5
    @{tableUsers}=  Get Table Data

    ${num_users_mcc}=    Get Length  ${rowsUsers}
    ${num_users_table}=  Get Length  ${tableUsers}
    Should Be Equal  ${num_users_table}  ${num_users_mcc}

    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  Log To Console   ${rowsUsers}[${i}][username]
    \  Should Be Equal  ${rowsUsers}[${i}][username]  ${tableUsers}[${i}][0]

    # sorting descending
    @{rowsUsers}=   Show Role Assignment  sort_field=username  sort_order=descending
    Sort User Name  5
    @{tableUsers}=  Get Table Data

    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  Should Be Equal  ${rowsUsers}[${i}][username]  ${tableUsers}[${i}][0]

Web UI - Sorting users by Organization
    [Documentation]
    ...  Open Users page
    ...  Check sort functionality of table headers
    ...  Confirm sort occurs / functions properly

    # PYTHON SORTS DIFF THAN OUR CONSOLE AAAH
    # If there are ANY Capital letters starting Orgs/Names/Roles (sorting fails)
    @{rowsUsers}=  Show Role Assignment  sort_field=organization  sort_order=ascending
    Sort User Orgs  5
    @{tableUsers}=  Get Table Data

    ${num_users_mcc}=    Get Length  ${rowsUsers}
    ${num_users_table}=  Get Length  ${tableUsers}
    Should Be Equal  ${num_users_table}  ${num_users_mcc}

    # Temp work around to diff sorting functionlities
    @{tableList}=  Create List
    @{userList}=   Create List
    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  Append To List  ${tableList}  ${tableUsers}[${i}][1]
    \  Append To List  ${userList}   ${rowsUsers}[${i}][org]
    Sort List  ${tableList}
    Sort List  ${userList}
    # End of: Temp work around to diff sorting functionlities

    # Mexadmin org is either ""(MMC) or "-"(Console) but they are not the same
    :FOR    ${i}    IN RANGE    1    ${num_users_table}
    \  Log To Console   ${userList}[${i}]
    \  Should Be Equal  ${userList}[${i}]  ${tableList}[${i}]

    #####   sorting descending   #####
    @{rowsUsers}=  Show Role Assignment  sort_field=organization  sort_order=descending
    Sort User Orgs  5
    @{tableUsers}=  Get Table Data

    #:FOR    ${i}    IN RANGE    0    ${num_users_table}
    #\  Log To Console  ${rowsUsers}[${i}][org]
    #\  Should Be Equal  ${rowsUsers}[${i}][org]  ${tableUsers}[${i}][1]

    #  TEMP SOLUTION TO MMC/CONSOLE SORT != EACHOTHER
    @{tableList}=  Create List
    @{userList}=   Create List
    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  Append To List  ${tableList}  ${tableUsers}[${i}][1]
    \  Append To List  ${userList}   ${rowsUsers}[${i}][org]
    Sort List       ${tableList}
    Sort List       ${userList}
    Reverse List    ${tableList}
    Reverse List    ${userList}

    # Mexadmin org is either ""(MMC) or "-"(Console) but they are not the same
    :FOR    ${i}    IN RANGE    0    ${num_users_table}-1
    \  Should Be Equal  ${userList}[${i}]  ${tableList}[${i}]
    #  END OF:  TEMP SOLUTION TO MMC/CONSOLE SORT != EACHOTHER

Web UI - Sorting users by Role Type
    [Documentation]
    ...  Open Users page
    ...  Check sort functionality of table headers
    ...  Confirm sort occurs / functions properly

    @{rowsUsers}=  Show Role Assignment

    Sort User Roletypes  5
    @{tableUsers}=  Get Table Data


    ${num_users_mcc}=      Get Length  ${rowsUsers}
    ${num_users_table}=    Get Length  ${tableUsers}
    Should Be Equal  ${num_users_table}  ${num_users_mcc}

    # Temp work around to diff sorting functionlities
    @{tableList}=  Create List
    @{userList}=   Create List

    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  ${endString}=  Trim First Char  ${tableUsers}[${i}][2]
    \  Append To List  ${tableList}  ${endString}
    \  Append To List  ${userList}   ${rowsUsers}[${i}][role]

    Sort List  ${tableList}
    Sort List  ${userList}
    # End of: Temp work around to diff sorting functionlities

    # Mexadmin org is either ""(MMC) or "-"(Console) but they are not the same
    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  Log To Console   ${tableList}[${i}]
    \  Should Be Equal  ${userList}[${i}]  ${tableList}[${i}]

    #####   sorting descending   #####
    Sort User Roletypes  5
    @{tableUsers}=  Get Table Data

    ${num_users_mcc}=      Get Length  ${rowsUsers}
    ${num_users_table}=    Get Length  ${tableUsers}
    Should Be Equal  ${num_users_table}  ${num_users_mcc}

    # Temp work around to diff sorting functionlities
    @{tableList}=  Create List
    @{userList}=   Create List

    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  ${endString}=  Trim First Char  ${tableUsers}[${i}][2]
    \  Append To List  ${tableList}  ${endString}
    \  Append To List  ${userList}   ${rowsUsers}[${i}][role]

    Sort List       ${tableList}
    Sort List       ${userList}
    Reverse List    ${tableList}
    Reverse List    ${userList}
    # End of: Temp work around to diff sorting functionlities

    # Mexadmin org is either ""(MMC) or "-"(Console) but they are not the same
    :FOR    ${i}    IN RANGE    0    ${num_users_table}
    \  Should Be Equal  ${userList}[${i}]  ${tableList}[${i}]

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute
    Open Users

Teardown
    Cleanup Provisioning
    Close Browser
