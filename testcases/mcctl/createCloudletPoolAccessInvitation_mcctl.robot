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
${version}=  latest

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

      Error: Bad Request (400), Specified developer organization not found  cloudletpool=x  cloudletpoolorg=tmus  org=x
      Error: Bad Request (400), Specified CloudletPool x org x for region US not found  cloudletpool=x  cloudletpoolorg=x  org=${developer_org_name_automation}

# ECQ-3321
CreateCloudletPoolAccessResponse - mcctl shall be able to create/show/delete/pending/granted response with decision=accept
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse/ShowCloudletPoolAccessResponse/DeleteCloudletPoolAccessReponse via mcctl with decision=accept
   ...  - verify response is created/shown/deleted

   [Tags]  CloudletPoolAccess

   [Setup]  Setup Invitation
   [Teardown]  Teardown Invitation

   [Template]  Success Create/Show/Delete Accept Response Via mcctl
      cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}  decision=accept

# ECQ-3353
CreateCloudletPoolAccessResponse - mcctl shall be able to create/show/delete/pending/granted response with decision=reject
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse/ShowCloudletPoolAccessResponse/DeleteCloudletPoolAccessReponse via mcctl with decision=reject
   ...  - verify response is created/shown/deleted

   [Tags]  CloudletPoolAccess

   [Setup]  Setup Invitation
   [Teardown]  Teardown Invitation

   [Template]  Success Create/Show/Delete Reject Response Via mcctl
      cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}  decision=reject

# ECQ-3322
CreateCloudletPoolAccessResponse - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateCloudletPoolAccessResponse via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   [Setup]  Setup Invitation
   [Teardown]  Teardown Invitation

   [Template]  Fail Create Confirmation Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl

      Error: missing required args:  cloudletpool=${pool_name}
      Error: missing required args:  cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}
      Error: missing required args:  cloudletpool=${pool_name}  org=${developer_org_name_automation}
      Error: missing required args:  cloudletpoolorg=${operator_name_crm}
      Error: missing required args:  org=${developer_org_name_automation}
      Error: missing required args:  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}

      Error: missing required args: decision  cloudletpool=x  cloudletpoolorg=x  org=x

      Error: Bad Request (400), No invitation for specified cloudlet pool access  cloudletpool=x  cloudletpoolorg=x  org=x  decision=accept
      Error: Bad Request (400), No invitation for specified cloudlet pool access  cloudletpool=x  cloudletpoolorg=x  org=x  decision=reject

      Error: Bad Request (400), Decision must be either accept or reject  cloudletpool=${pool_name}  cloudletpoolorg=${operator_name_crm}  org=${developer_org_name_automation}  decision=x

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
   ${showp}=  Run mcctl  cloudletpoolinvitation showpending region=${region} ${parmss}  version=${version}  token=${token}
   ${showg}=  Run mcctl  cloudletpoolinvitation showgranted region=${region} ${parmss}  version=${version}  token=${token}
   ${delete}=  Run mcctl  cloudletpoolinvitation delete region=${region} ${parmss}  version=${version}  token=${token}

   Should Be Equal  ${create}  Invitation created\n

   Should Be Equal  ${show[0]['CloudletPool']}  ${pool_name} 
   Should Be Equal  ${show[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${show[0]['Region']}  ${region}
   Should Be Equal  ${show[0]['Org']}  ${parms['org']}

   Should Be Equal  ${showp[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${showp[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${showp[0]['Region']}  ${region}
   Should Be Equal  ${showp[0]['Org']}  ${parms['org']}

   Length Should Be  ${showg}  0

   Should Be Equal  ${delete}  Invitation deleted\n

Success Create/Show/Delete Accept Response Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   Remove From Dictionary  ${parms}  decision
   ${parmss_alter}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
 
   ${create}=  Run mcctl  cloudletpoolresponse create region=${region} ${parmss}  version=${version}  token=${token}
   ${granted_resp}=  Run mcctl  cloudletpoolresponse showgranted region=${region}  version=${version}  token=${token}
   ${granted_invi}=  Run mcctl  cloudletpoolinvitation showgranted region=${region}  version=${version}  token=${token}
   ${show}=  Run mcctl  cloudletpoolresponse show region=${region} ${parmss}  version=${version}  token=${token}
   ${showp_invi}=  Run mcctl  cloudletpoolinvitation showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_invi}=  Run mcctl  cloudletpoolinvitation showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showp_resp}=  Run mcctl  cloudletpoolresponse showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_resp}=  Run mcctl  cloudletpoolresponse showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${delete}=  Run mcctl  cloudletpoolresponse delete region=${region} ${parmss}  version=${version}  token=${token}
   ${showp_del_invi}=  Run mcctl  cloudletpoolinvitation showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_del_invi}=  Run mcctl  cloudletpoolinvitation showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showp_del_resp}=  Run mcctl  cloudletpoolresponse showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_del_resp}=  Run mcctl  cloudletpoolresponse showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}

   Should Be Equal  ${create}  Response created\n

   Should Be Equal  ${show[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${show[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${show[0]['Region']}  ${region}
   Should Be Equal  ${show[0]['Org']}  ${parms['org']}
   Should Be Equal  ${show[0]['Decision']}  accept

   Should Be Equal  ${granted_resp}  ${granted_invi}
   Should Be True  len(${granted_resp}) > 0
   Should Be True  len(${granted_resp}) > 0

   Length Should Be  ${showp_invi}  0
   Length Should Be  ${showp_resp}  0

   Should Be Equal  ${showg_invi[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${showg_invi[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${showg_invi[0]['Region']}  ${region}

   Should Be Equal  ${showg_resp[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${showg_resp[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${showg_resp[0]['Region']}  ${region}
   Should Be Equal  ${showg_resp[0]['Org']}  ${parms['org']}

   Should Be Equal  ${delete}  Response deleted\n

   Should Be Equal  ${showp_del_invi[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${showp_del_invi[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${showp_del_invi[0]['Region']}  ${region}
   Should Be Equal  ${showp_del_invi[0]['Org']}  ${parms['org']}

   Should Be Equal  ${showp_del_resp[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${showp_del_resp[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${showp_del_resp[0]['Region']}  ${region}
   Should Be Equal  ${showp_del_resp[0]['Org']}  ${parms['org']}

   Length Should Be  ${showg_del_resp}  0
   Length Should Be  ${showg_del_invi}  0

Success Create/Show/Delete Reject Response Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   Remove From Dictionary  ${parms}  decision
   ${parmss_alter}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${create}=  Run mcctl  cloudletpoolresponse create region=${region} ${parmss}  version=${version}  token=${token}
   ${granted_resp}=  Run mcctl  cloudletpoolresponse showgranted region=${region}  version=${version}  token=${token}
   ${granted_invi}=  Run mcctl  cloudletpoolinvitation showgranted region=${region}  version=${version}  token=${token}
   ${show}=  Run mcctl  cloudletpoolresponse show region=${region} ${parmss}  version=${version}  token=${token}
   ${showp_invi}=  Run mcctl  cloudletpoolinvitation showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_invi}=  Run mcctl  cloudletpoolinvitation showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showp_resp}=  Run mcctl  cloudletpoolresponse showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_resp}=  Run mcctl  cloudletpoolresponse showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${delete}=  Run mcctl  cloudletpoolresponse delete region=${region} ${parmss}  version=${version}  token=${token}
   ${showp_del_invi}=  Run mcctl  cloudletpoolinvitation showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_del_invi}=  Run mcctl  cloudletpoolinvitation showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showp_del_resp}=  Run mcctl  cloudletpoolresponse showpending region=${region} ${parmss_alter}  version=${version}  token=${token}
   ${showg_del_resp}=  Run mcctl  cloudletpoolresponse showgranted region=${region} ${parmss_alter}  version=${version}  token=${token}

   Should Be Equal  ${create}  Response created\n

   Should Be Equal  ${show[0]['CloudletPool']}  ${pool_name}
   Should Be Equal  ${show[0]['CloudletPoolOrg']}  ${parms['cloudletpoolorg']}
   Should Be Equal  ${show[0]['Region']}  ${region}
   Should Be Equal  ${show[0]['Org']}  ${parms['org']}
   Should Be Equal  ${show[0]['Decision']}  reject

   Should Be Equal  ${granted_invi}  ${granted_resp}
   Should Be True  len(${granted_invi}) >= 0
   Should Be True  len(${granted_resp}) >= 0

   Should Be True  len(${showp_invi}) >= 0
   Should Be True  len(${showp_resp}) >= 0

   Length Should Be  ${showg_invi}  0
   Length Should Be  ${showg_resp}  0

   Should Be Equal  ${delete}  Response deleted\n

   Should Be True  len(${showp_del_invi}) >= 0
   Should Be True  len(${showp_del_resp}) >= 0

   Length Should Be  ${showg_del_invi}  0
   Length Should Be  ${showg_del_resp}  0

Fail Create Invitation Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudletpoolinvitation create region=${region} ${parmss}    version=${version}  token=${token}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Create Confirmation Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudletpoolresponse create region=${region} ${parmss}    version=${version}  token=${token}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

