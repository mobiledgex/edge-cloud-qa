*** Settings ***
Documentation  ShowAlertReceiver

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning
 
Test Timeout  1m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

*** Test Cases ***
ShowAlertReceiver - shall be able to show all alert receivers
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   ${alert}=  Show Alert Receivers  

   Receivers Data Should Be Good  ${alert}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Privacy Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

Receivers Data Should Be Good
   [Arguments]  ${alert}

   FOR  ${a}  IN  @{alert}
      Should Be True  len('${a['Name']}') > 0
      Should Be True  '${a['Type']}' == 'email' or '${a['Type']}' == 'slack'
      Should Be True  '${a['Severity']}' == 'info' or '${a['Severity']}' == 'error' or '${a['Severity']}' == 'warn'
      Should Be True  len('${a['User']}') > 0
      #Should Be True  len('${a['Email']}') > 0
   END
