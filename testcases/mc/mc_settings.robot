*** Settings ***
Documentation   MasterController Org Create as Admin

Library         MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime

Test Setup      Setup
#Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=    mextester06
${password}=    H31m8@W8maSfg
${adminuser}=   mextester06admin
${adminpass}=   mexadminfastedgecloudinfra

*** Test Cases ***
# ECQ-2772
MC - Admin shall be able to show the config
   [Documentation]
   ...  pull the mc config using the admin token
   ...  verify the config items are returned

  ${settings}=   Show Settings 
  #Should Contain   ${config}   SkipVerifyEmail

