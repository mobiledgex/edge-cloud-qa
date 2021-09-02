*** Settings ***
Documentation  createCloudletPool mcctl

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
# ECQ-3826
CloudletPool - mcctl shall handle addmember failures
   [Documentation]
   ...  - send cloudletpool addmember via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Add Member Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl  

      Error: missing required args:  pool=${pool_name}
      Error: missing required args:  pool=${pool_name}  org=${operator_name_fake}
      Error: missing required args:  pool=${pool_name}  cloudlet=${cloudlet_name_fake}
      Error: missing required args:  org=${operator_name_fake}
      Error: missing required args:  cloudlet=${cloudlet_name_fake}   org=${operator_name_fake}

# ECQ-3827
CloudletPool - mcctl shall handle removemember failures
   [Documentation]
   ...  - send cloudletpool removemember via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Remove Member Via mcctl
      # missing values
      Error: missing required args:   #not sending any args with mcctl

      Error: missing required args:  pool=${pool_name}
      Error: missing required args:  pool=${pool_name}  org=${operator_name_fake}
      Error: missing required args:  pool=${pool_name}  cloudlet=${cloudlet_name_fake}
      Error: missing required args:  org=${operator_name_fake}
      Error: missing required args:  cloudlet=${cloudlet_name_fake}   org=${operator_name_fake}

*** Keywords ***
Setup
   ${pool_name}=  Get Default Cloudlet Pool Name
   ${token}=  Get Super Token

   Run mcctl  cloudletpool create region=${region} org=${operator_name_fake} name=${pool_name}  version=${version}  token=${token}

   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${token}

Fail Add Member Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudletpool addmember region=${region} ${parmss}    version=${version}  token=${token}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Remove Member Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudletpool removemember region=${region} ${parmss}    version=${version}  token=${token}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Teardown
   Run mcctl  cloudletpool delete region=${region} org=${operator_name_fake} name=${pool_name}  version=${version}  token=${token}

