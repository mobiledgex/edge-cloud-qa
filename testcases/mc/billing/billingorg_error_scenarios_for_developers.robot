*** Settings ***
Documentation  ErrorScenarios for Creating and Deleting Billing Org for Developers
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
### ECQ-3886
GenerateErrorMessage - generate an error when developer tries to create billing org

    Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal  ${body}      {"message":"Organization created"}

    ${error}=  Run Keyword And Expect Error  *  Create Billing Org  billing_org_name=${dev_orgname}  billing_org_type=self  first_name=QA  last_name=Billing  email_address=devorg@mobiledgex.com
    Should Contain   ${error}  code=400
    Should Contain   ${error}  error={"message":"Currently only admins may create and commit billingOrgs"}

GenerateErrorMessage - generate an error when developer tries to delete billing org

    ${error}=  Run Keyword And Expect Error  *  Delete Billing Org  billing_org_name=${dev_orgname}
    Should Contain   ${error}  code=400
    Should Contain   ${error}  error={"message":"Currently only admins may create and commit billingOrgs"}


*** Keywords ***
Setup
   ${adminToken}=   Login  username=${username}  password=${password}

   Set Suite Variable  ${adminToken}

   billing enable  true

Cleanup Provisioning
   billing enable  false
