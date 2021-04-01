*** Settings ***
Documentation  createCloudletPoolAccess mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Teardown

Test Timeout  2m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${version}=  2021-03-23

*** Test Cases ***
# ECQ-3319
CreateCloudletPoolAccessInvitation - mcctl shall be able to create/show/delete invitation
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation/ShowCloudletPoolAccessInvitation/DeleteCloudletPoolAccessInvitation via mcctl with various parms
   ...  - verify invitation is created/shown/deleted

   [Tags]  CloudletPoolAccess

   [Template]  Success Create/Show/Delete Invitation Via mcctl
      cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}

# ECQ-3320
CreateCloudletPoolAccessInvitation - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateCloudletPoolAccessInvitation via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   [Template]  Fail Create Invitation Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl  

      Error: missing required args:  cloudletpool=${pool_name}
      Error: missing required args:  cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}
      Error: missing required args:  cloudletpool=${pool_name}  org=${developer_org_name_automation}
      Error: missing required args:  cloudletpoolorg=${operator_name_crm}
      Error: missing required args:  org=${developer_org_name_automation}
      Error: missing required args:  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}

      Error: Bad Request (400), Specified CloudletPool x org x for region US not found  cloudletpool=x  cloudletpoolorg=x  org=x

# ECQ-3321
CreateCloudletPoolAccessConfirmation - mcctl shall be able to create/show/delete/granted confirmation
   [Documentation]
   ...  - send CreateCloudletPoolAccessConfirmation/ShowCloudletPoolAccessConfirmation/DeleteCloudletPoolAccessConfirmation via mcctl with various parms
   ...  - verify confirmation is created/shown/deleted

   [Tags]  CloudletPoolAccess

   [Setup]  Setup Invitation
   [Teardown]  Teardown Invitation

   [Template]  Success Create/Show/Delete Confirmation Via mcctl
      cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}

# ECQ-3322
CreateCloudletPoolAccessConfirmation - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateCloudletPoolAccessConfirmation via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   [Template]  Fail Create Confirmation Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl

      Error: missing required args:  cloudletpool=${pool_name}
      Error: missing required args:  cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}
      Error: missing required args:  cloudletpool=${pool_name}  org=${developer_org_name_automation}
      Error: missing required args:  cloudletpoolorg=${operator_name_crm}
      Error: missing required args:  org=${developer_org_name_automation}
      Error: missing required args:  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}

      Error: Bad Request (400),  No invitation for specified cloudlet pool access  cloudletpool=x  cloudletpoolorg=x  org=x

*** Keywords ***
Setup
   ${pool_name}=  Get Default Cloudlet Pool Name
   ${token}=  Get Super Token

   Run mcctl  cloudletpool create region=${region} region=${region} org=${operator_name_crm} name=${pool_name}  version=${version}  token=${token}

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${token}

Setup Invitation
   Setup
   Run mcctl  cloudletpoolinvitation create region=${region} cloudletpool=${pool_name} cloudletpoolorg=${operator_name_crm} org=${developer_org_name_automation}  version=${version}  token=${token}

Teardown Invitation
   Run mcctl  cloudletpoolinvitation delete region=${region} cloudletpool=${pool_name} cloudletpoolorg=${operator_name_crm} org=${developer_org_name_automation}  version=${version}  token=${token}
   Teardown
 
Teardown
   Run mcctl  cloudletpool delete region=${region} region=${region} org=${operator_name_crm} name=${pool_name}  version=${version}  token=${token}

Success Create/Show/Delete Invitation Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${create}=  Run mcctl  cloudletpoolinvitation create region=${region} ${parmss}  version=${version}  token=${token}
   ${show}=  Run mcctl  cloudletpoolinvitation show region=${region} ${parmss}  version=${version}  token=${token}
   ${delete}=  Run mcctl  cloudletpoolinvitation delete region=${region} ${parmss}  version=${version}  token=${token}

   Should Be Equal  ${create}  invitation created\n

   Should Be Equal  ${show[0]['CloudletPool']}  ${pool_name} 
   Should Be Equal  ${show[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${show[0]['Region']}  ${region}
   Should Be Equal  ${show[0]['Org']}  ${parms['org']}

   Should Be Equal  ${delete}  invitation deleted\n

Success Create/Show/Delete Confirmation Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${create}=  Run mcctl  cloudletpoolconfirmation create region=${region} ${parmss}  version=${version}  token=${token}
   ${granted1}=  Run mcctl  cloudletpoolconfirmation showgranted region=${region}  version=${version}  token=${token}
   ${granted2}=  Run mcctl  cloudletpoolinvitation showgranted region=${region}  version=${version}  token=${token}
   ${show}=  Run mcctl  cloudletpoolconfirmation show region=${region} ${parmss}  version=${version}  token=${token}
   ${delete}=  Run mcctl  cloudletpoolconfirmation delete region=${region} ${parmss}  version=${version}  token=${token}

   Should Be Equal  ${create}  confirmation created\n

   Should Be Equal  ${show[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${show[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${show[0]['Region']}  ${region}
   Should Be Equal  ${show[0]['Org']}  ${parms['org']}

   Should Be Equal  ${granted1}  ${granted2}
   Should Be True  len(${granted1}) > 0
   Should Be True  len(${granted2}) > 0

   Should Be Equal  ${delete}  confirmation deleted\n

Fail Create Invitation Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudletpoolinvitation create region=${region} ${parmss}    version=${version}  token=${token}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Create Confirmation Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudletpoolconfirmation create region=${region} ${parmss}    version=${version}  token=${token}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

