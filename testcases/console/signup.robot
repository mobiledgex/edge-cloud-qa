*** Settings ***
Documentation     signup user

Library         MexConsole  %{AUTOMATION_CONSOLE_ADDRESS}

Test Teardown   Close Browser

Test Timeout    5 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
User shall be able to signup a new user
    Open Signup
    Signup New User  username=andy  password=andypass  confirm_password=andypass  email=andya072071@gmail.com

    sleep  10s