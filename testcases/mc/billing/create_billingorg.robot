*** Settings ***
Documentation  CreateBillingOrg, Verify Account is created in Chargify and MexAdmin can get Invoice
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Test Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
#${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw
${dev_orgname}=    DevOrg
${op_orgname}=     OperOrg

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${mex_password}=  ${mexadmin_password}

*** Test Cases ***
### ECQ-3876
Create DevOrg, Billingorg and Verify integration works with Chargify via Show account info.

    Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal  ${body}      {"message":"Organization created"}

    Create Billing Org  billing_org_name=${dev_orgname}  billing_org_type=self  first_name=QA  last_name=Billing  email_address=devorg@mobiledgex.com

    ${account_info}=  show account info
    Org Should Be In List  ${account_info}  ${devorg_name}

    ${resp}=  response status code
    Should Be Equal As Integers  ${resp}  200

Get Invoice for Billing Org

    ${invoices}=  get invoice  billing_org_name=Test2-Billing  start_date=2021-08-26  end_date=2021-08-26

    should be equal  ${invoices[0]['customer']['first_name']}  Test1
    should be equal  ${invoices[0]['customer']['organization']}  Test2-Billing
    should be equal  ${invoices[0]['line_items'][0]['period_range_end']}  2021-08-27
    should be equal  ${invoices[0]['line_items'][0]['period_range_start']}  2021-08-25


    Length Should Be  ${invoices}  1


*** Keywords ***
Setup
   ${adminToken}=   Login  username=mexadmin  password=${mex_password}

   Set Suite Variable  ${adminToken}

   Billing Enable  true

Cleanup Provisioning

   Billing Enable  false

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

