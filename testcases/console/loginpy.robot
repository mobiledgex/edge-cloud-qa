*** Settings ***
Documentation   Login to console

Library		MexConsole  url=http://console.mobiledgex.net
#Library         SeleniumLibrary
	
Test Teardown   Close Browser

Test Timeout    40 minutes
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
Login to console
    [Documentation]
    ...  Create 2 clusters and cluster instances at the same time on openstack
    ...  Verify both are created successfully

    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

    Get Organization Data