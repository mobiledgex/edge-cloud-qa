*** Settings ***
Documentation   Verify correct flavors

Library		MexConsole  url=http://console.mobiledgex.net
#Library         SeleniumLibrary

Test Teardown   Close Browser

Test Timeout    20 minutes

#variables stay the same: don't change Charlie
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
Login to console
    [Documentation]
    ...  Click Flavors on left menu
    ...  Verify all flavors show properly with proper table formatting

    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

    Open Flavors
