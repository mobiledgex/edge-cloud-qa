*** Settings ***
Documentation  Developer can view Invoice of their Billing Org
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Test Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
#${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw
${dev_orgname}=    DevOrg
${op_orgname}=     OperOrg

${username}=  testuser
${password}=  testuser
${mex_password}=  ${mexadmin_password}

*** Test Cases ***
### ECQ-3879

Get Invoice for Billing Org

    ${invoices}=  get invoice  billing_org_name=Test2-Billing  start_date=2021-08-26  end_date=2021-08-26

    should be equal  ${invoices[0]['customer']['first_name']}  Test1
    should be equal  ${invoices[0]['customer']['organization']}  Test2-Billing
    should be equal  ${invoices[0]['line_items'][0]['period_range_end']}  2021-08-27
    should be equal  ${invoices[0]['line_items'][0]['period_range_start']}  2021-08-25


    Length Should Be  ${invoices}  1

*** Keywords ***
Setup
   ${adminToken}=   Login  username=${username}  password=${password}

   Set Suite Variable  ${adminToken}

Org Should Be In List
      [Arguments]  ${account_list}  ${devorg_name}

      ${found}=  Set Variable  ${False}
      FOR  ${account}  IN  @{account_list}
        IF  "${account['OrgName']}" == '${devorg_name}'
             ${found}=  Set Variable  ${True}
          Exit For Loop
        END
      END

   Run Keyword If  ${found} == ${False}  Fail  Account ${account_name} not found
