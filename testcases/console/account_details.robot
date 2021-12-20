*** Settings ***
Documentation   Click and Verify Account Data

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

*** Test Cases ***
WebUI - Account details should be possible to view
    [Documentation]
    ...  Sign in as mexadmin
    ...  Load Accounts page
    ...  View all accounts and confirm data visible

    Open Accounts
    @{rowsAccounts}=  Show Accounts
    Sort Account Name  2

     :FOR    ${row}    IN     @{rowsAccounts}
     \  Log To Console        ${row['Name']}
     \  Account Should Exist  account_name=${row['Name']}  email=${row['Email']}
     \  ${details_acc}=  View Account Details  account_name=${row['Name']}  #email=${row['Email']}
     \  ${createdAt}=    Evaluate    """${row}[CreatedAt]"""[:10]
     \  ${updatedAt}=    Evaluate    """${row}[UpdatedAt]"""[:10]
     \  Should Be Equal       ${createdAt}  ${details_acc}[CreatedAt]
     \  Should Be Equal       ${updatedAt}  ${details_acc}[UpdatedAt]
     \  Should Be Equal       ${row}[Email]  ${details_acc}[Email]
     \  Should Be Equal       ${row}[EmailVerified]  ${details_acc}[EmailVerified]
     \  Should Be Equal       ${row}[Name]  ${details_acc}[Username]
#     \  Should Be Equal       ${row}[Passhash]  ${details_acc}[Passhash]
#     \  Should Be Equal       ${row}[Nickname]  ${details_acc}[Nickname]
#     \  Should Be Equal       ${row}[Iter]  ${details_acc}[Iter]
#     \  Should Be Equal       ${row}[GivenName]  ${details_acc}[GivenName]
#     \  Should Be Equal       ${row}[Picture]  ${details_acc}[Picture]
#     \  Should Be Equal       ${row}[Salt]  ${details_acc}[Salt]
     \  Close Account Details

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
