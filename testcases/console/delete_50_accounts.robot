*** Settings ***
Documentation   Delete 50 accounts
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

#Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min

${username}          HackTeam


*** Test Cases ***
Web UI - Delete 50 account from backend 
    [Documentation]
    ...  delete accounts

    :FOR    ${i}    IN RANGE    50
    \  ${number}=  Evaluate  ${i}+1
    \  ${username1}=  Catenate  SEPARATOR=  ${username}  ${number}
    \  Delete User  username=${username1}

*** Keywords ***
Teardown
    
    Cleanup Provisioning
