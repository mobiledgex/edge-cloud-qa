*** Settings ***
Documentation  CreateCloudlet mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${operator}=  tmus

${version}=  latest

*** Test Cases ***
# ECQ-3085
CreateCloudlet - mcctl shall be able to create/show/delete cloudlet
   [Documentation]
   ...  - send CreateCloudlet/ShowCloudlet/DeleteCloudlet via mcctl with various parms
   ...  - verify app is created/shown/deleted

   [Template]  Success Create/Show/Delete Cloudlet Via mcctl
      # trusted
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  trustpolicy=${trustpolicy_name} 
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  trustpolicy=

# ECQ-3086
CreateCloudlet - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateCloudlet via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Cloudlet Via mcctl
      # missing values
      #Error: Bad Request (400), Unknown image type IMAGE_TYPE_UNKNOWN  appname=${app_name}  app-org=${developer}  appvers=1.0

      # trusted
      Error: OK (200), TrustPolicy x for organization tmus not found  cloudlet=${cloudlet_name}  cloudlet-org=${operator}  location.latitude=1  location.longitude=1  numdynamicips=1  platformtype=PlatformTypeFake  trustpolicy=x

# ECQ-3087
UpdateCloudlet - mcctl shall handle update cloudlet 
   [Documentation]
   ...  - send UpdateCloudlet via mcctl with various args
   ...  - verify proper is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Cloudlet Via mcctl
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  trustpolicy=${trustpolicy_name} 
      cloudlet=${cloudlet_name}  cloudlet-org=${operator}  trustpolicy=
 
*** Keywords ***
Setup
   ${cloudlet_name}=  Get Default Cloudlet Name

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}
   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator}
   ${trustpolicy_name}=  Set Variable  ${policy_return['data']['key']['name']}
   
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${trustpolicy_name}
 
Success Create/Show/Delete Cloudlet Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  deploymentmanifest
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
 
   Run mcctl  cloudlet create region=${region} ${parmss} --debug  version=${version}
   ${show}=  Run mcctl  cloudlet show region=${region} ${parmss_modify}  version=${version}
   Run mcctl  cloudlet delete region=${region} ${parmss_modify}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['cloudlet']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cloudlet-org']}
   Should Be Equal As Numbers  ${show[0]['location']['latitude']}   ${parms['location.latitude']}
   Should Be Equal As Numbers  ${show[0]['location']['longitude']}  ${parms['location.longitude']}
   Should Be Equal As Numbers  ${show[0]['num_dynamic_ips']}        ${parms['numdynamicips']}
   Should Be Equal As Numbers  ${show[0]['state']}                  5

   Run Keyword If  'trustpolicy' in ${parms} and '${parms['trustpolicy']}' != '${Empty}'  Should Be Equal  ${show[0]['trust_policy']}  ${parms['trustpolicy']} 
   ...  ELSE  Should Not Contain  ${show[0]}  trust_policy
   Run Keyword If  'trustpolicy' in ${parms} and '${parms['trustpolicy']}' != '${Empty}'  Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  5
 
Update Setup
   #${cloudlet_name}=  Get Default Cloudlet Name

   #Set Suite Variable  ${cloudlet_name}

   Setup 

   Run mcctl  cloudlet create region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} location.latitude=1 location.longitude=1 numdynamicips=1 platformtype=PlatformTypeFake 

Update Teardown
   Run mcctl  cloudlet delete region=${region} cloudlet=${cloudlet_name} cloudlet-org=${operator} location.latitude=1 location.longitude=1 numdynamicips=1

Success Update/Show Cloudlet Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  cloudlet update region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  cloudlet show region=${region} ${parmss}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['cloudlet']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cloudlet-org']}
   Should Be Equal As Numbers  ${show[0]['state']}                  5

   Run Keyword If  'trustpolicy' in ${parms} and '${parms['trustpolicy']}' != '${Empty}'  Should Be Equal  ${show[0]['trust_policy']}  ${parms['trustpolicy']}
   ...  ELSE  Should Not Contain  ${show[0]}  trust_policy
   Run Keyword If  'trustpolicy' in ${parms} and '${parms['trustpolicy']}' != '${Empty}'  Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  5
   ...  ELSE  Should Be Equal As Numbers  ${show[0]['trust_policy_state']}  1

Fail Create Cloudlet Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  cloudlet create region=${region} ${parmss}  version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
