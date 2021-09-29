*** Settings ***
Documentation  BillingOrg mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${billing_org_name}=  BillingDev

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${mex_password}=  ${mexadmin_password}


*** Test Cases ***
### ECQ-3990 ###
CreateBillingOrg - mcctl shall be able to create/delete BillingOrg

   [Documentation]
   ...  - send Create/Show/Delete BillingOrg via mcctl with various parms
   ...  - verify BillingOrg is created/shown/deleted

   [Template]  Success Create/Delete Billing Org Via mcctl

   name=${billing_org_name}  firstname=test  lastname=bill  email=testbill@gmail.com  type=self

CreateBillingOrg - mcctl shall handle create failures with name only

    [Documentation]
   ...  - send CreateBillingOrg via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail to Create Billing Org Via mcctl with name only
      Error: missing required args: firstname lastname email type  name=${billing_org_name}
      Error: missing required args: type lastname email  name=${billing_org_name}  fistname=testuser
      Error: missing required args: type email  name=${billing_org_name}  fistname=testuser  lastname=billing


*** Keywords ***
Setup
   ${adminToken}=   Login  username=mexadmin  password=${mex_password}

   Set Suite Variable  ${adminToken}

   Create Org    orgname=${billing_org_name}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
    Should Be Equal  ${body}      {"message":"Organization created"}

#   ${billing_org_name}=  Get Billing Org Name
   Set Suite Variable   ${billing_org_name}

Success Create/Delete Billing Org Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  billingorg create ${parmss}
   Run mcctl  billingorg delete ${parmss}

Fail to Create Billing Org Via mcctl with name only
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  billingorg create ${parmss}


