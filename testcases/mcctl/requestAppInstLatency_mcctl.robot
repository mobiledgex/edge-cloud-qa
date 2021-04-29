*** Settings ***
Documentation  RequestAppInstLatency mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-3238
RequestAppInstLatency - mcctl shall be able to request latency
   [Documentation]
   ...  - send RequestAppInstLatency via mcctl with various parms
   ...  - verify success

   [Tags]  DMEPersistentConnection

   [Template]  Success RequestAppInstLatency Via mcctl
      appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0 cluster=autoclusterautomation cluster-org=${developer}  cloudlet=${cloudlet_name_fake} cloudlet-org=${operator_name_fake}
      appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0 cluster=autoclusterautomation cluster-org=${developer}  cloudlet=${cloudlet_name_fake} cloudlet-org=${operator_name_fake} message=xxxxx
      appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0 cluster=autoclusterautomation cluster-org=${developer}  cloudlet=${cloudlet_name_fake} cloudlet-org=${operator_name_fake} message=

# ECQ-3239
RequestAppInstLatency - mcctl shall handle create failures
   [Documentation]
   ...  - send RequestAppInstLatency via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  DMEPersistentConnection

   [Template]  Fail RequestAppInstLatency Via mcctl
      # invalid values
      Error: missing required args: 
      Error: missing required args:  appname=  
      Error: missing required args:  appvers=1.0
      Error: missing required args:  app-org=${developer_org_name_automation}
      Error: missing required args:  cloudlet=${cloudlet_name_fake}
      Error: missing required args:  cloudlet-org=${operator_name_fake}
      Error: missing required args:  appname=${app_name_automation} appvers=1.0 app-org=${developer_org_name_automation}
      Error: missing required args:  appname=${app_name_automation} appvers=1.0 app-org=${developer_org_name_automation} cloudlet=${cloudlet_name_fake}

*** Keywords ***
Setup
   ${flavor_name}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name}

Success RequestAppInstLatency Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  appinstlatency request region=${region} ${parmss}  version=${version}

   Should Be Equal  ${result['message']}  successfully sent latency request

Fail RequestAppInstLatency Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  appinstlatency request region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
