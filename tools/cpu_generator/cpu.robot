*** Settings ***
Documentation  CPU test 

Library  MexApp

#Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm}

*** Variables ***
${host}  andycpu.automationfrankfurtcloudlet.tdg.mobiledgex.net 
${port}  2017
${load}  40

${test_timeout_crm}  15 min

*** Test Cases ***
Set CPU
    [Documentation]
    ...  set cpu 

    Set CPU Load  host=${host}  port=${port}  load_percentage=${load} 
