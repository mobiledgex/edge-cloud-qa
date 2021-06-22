*** Settings ***
Documentation  CreateBillingOrg
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

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
CreatedevOrg - shall be able to create Developer org

    Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal  ${body}      {"message":"Organization created"}

CreateBillingOrg - shall be able to create Billing org
    Create Billing Org  billing_org_name=${dev_orgname}  billing_org_type=self  first_name=QA  last_name=Billing  email_address=devorg@mobiledgex.com



#    ${body}=         Response Body
#    should be equal  ${body}     {"message":"Billing Organization created"}

#DeleteBillingOrg - shall be able to delete Billing Org
#    delete billing org  billing_org_name=${dev_orgname}  token=${adminToken}
#    ${body}=         Response Body
#    should be equal  ${body}     {"message":"Billing Organization created"}



*** Keywords ***
Setup
   ${adminToken}=   Login  username=mexadmin  password=${mex_password}

   Set Suite Variable  ${adminToken}


