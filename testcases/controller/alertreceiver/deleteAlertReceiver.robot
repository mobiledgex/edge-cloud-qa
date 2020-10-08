*** Settings ***
Documentation  CreatePrivacyPolicy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning
 
Test Timeout  1m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

*** Test Cases ***
CreatePrivacyPolicy - shall be able to create with policy and developer name only
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   ${rcv_name}=  Get Default Alert Receiver Name 

   ${alert}=  Create Alert Receiver  receiver_name=${rcv_name}  developer_org_name=${developer}  #use_defaults=${False}

   Alert Receiver Should Exist

   Should Be Equal  ${alert['data']['key']['name']}       ${rcv_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${developer}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Privacy Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
