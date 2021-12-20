*** Settings ***
Documentation   Delete 50 cluster instances
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

#Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${timeout}           10 min
${username}          jclustertest

*** Test Cases ***
Web UI - Delete 50 cluster instances
    [Documentation]
    ...  delete cluster instances

    :FOR    ${i}    IN RANGE    50
    \  ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
    \  Delete Cluster Instance  username=${username1}

*** Keywords ***
Teardown
    Cleanup Provisioning