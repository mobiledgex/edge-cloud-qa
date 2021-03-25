*** Settings ***
Documentation  CreateAutoProvPolicy mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  2m

*** Variables ***
${region}=  EU
${developer}=  MobiledgeX

*** Test Cases ***
# ECQ-2827
CreateAutoProvPolicy - mcctl shall be able to create/show/delete policy
   [Documentation]
   ...  - send CreatePrivacyPolicy/ShowPrivacyPolicy/DeletePrivacyPolicy via mcctl with various parms
   ...  - verify policy is created/shown/deleted

   [Template]  Success Create/Show/Delete Auto Prov Policy Via mcctl
      # no protocol
#      name=${recv_name}  app-org=testmonitor

      # minactive
      name=${recv_name}  app-org=testmonitor  minactiveinstances=1  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

      # minactive and maxactive instance
      name=${recv_name}  app-org=testmonitor  minactiveinstances=1  maxinstances=2  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

      # deployclientcount
      name=${recv_name}  app-org=testmonitor  deployclientcount=1  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

      # deployclientcount and deployintervalcount
      name=${recv_name}  app-org=testmonitor  deployclientcount=1  deployintervalcount=1   cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

      # deployclientcount, deployintervalcount and minactiveinstances
      name=${recv_name}  app-org=testmonitor  deployclientcount=1  deployintervalcount=1  minactiveinstances=1   cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

      # deployclientcount, deployintervalcount, minactiveinstances and maxinstances
      name=${recv_name}  app-org=testmonitor  deployclientcount=1  deployintervalcount=1  minactiveinstances=1  maxinstances=2   cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

      # deployclientcount, deployintervalcount, minactiveinstances, maxinstances, undeployclientcount and undeployintervalcount
      name=${recv_name}  app-org=testmonitor  deployclientcount=1  deployintervalcount=1  minactiveinstances=1  maxinstances=2  undeployclientcount=1  undeployclientcount=2   cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

# ECQ-2828
CreateAutoProvPolicy - mcctl shall handle create failures
   [Documentation]
   ...  - send CreatePrivacyPolicy via mcctl with various error cases
   ...  - verify proper error is received

   [Template]   Fail Create Auto Provisioning Policy Via mcctl
      # missing values
      Error: missing required args: app-org name  Error: missing required args: name app-org  #not sending any args with mcctl

      Error: missing required args: name  app-org=${developer}  minactiveinstances=1  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: missing required args: app-org  name=${recv_name}  minactiveinstances=1  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: missing required args: app-org name  Error: missing required args: name app-org  minactiveinstances=1  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: invalid args: cloudlets:  Error: invalid args: cloudlets:  name=${recv_name}  region=${region}  app-org=testmonitor  minactiveinstances=1  cloudlets:.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: Bad Request (400), Cloudlet key {"organization":"TDG"} not found  Error: Bad Request (400), Cloudlet key {"organization":"TDG"} not found  name=${recv_name}  region=${region}  app-org=testmonitor  minactiveinstances=1  cloudlets:0.key.organization=TDG  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: Bad Request (400), Minimum active instances cannot be larger than Maximum Instances  Error: Bad Request (400), Minimum active instances cannot be larger than Maximum Instances  name=${recv_name}  region=${region}  app-org=testmonitor  minactiveinstances=2  maxinstances=1  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: Bad Request (400), One of deploy client count and minimum active instances must be specified  Error: Bad Request (400), One of deploy client count and minimum active instances must be specified  name=${recv_name}  region=${region}  app-org=testmonitor  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      Error: Bad Request (400), Minimum Active Instances cannot be larger than the number of Cloudlets  Error: Bad Request (400), Minimum Active Instances cannot be larger than the number of Cloudlets  name=${recv_name}  region=${region}  app-org=testmonitor  minactiveinstances=3  maxinstances=4  cloudlets:0.key.organization=TDG  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

UpdatePrivacyPolicy - mcctl shall handle update policy
   [Documentation]
   ...  - send UpdatePrivacyPolicy via mcctl with various args
   ...  - verify proper is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Privacy Policy Via mcctl
      name=${recv_name}  app-org=${developer}  region=${region}  cloudlets:0.key.organization=TDG  deployclientcount=1  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      name=${recv_name}  app-org=${developer}  region=${region}  cloudlets:0.key.organization=TDG  deployclientcount=1  deployintervalcount=2  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      name=${recv_name}  app-org=${developer}  region=${region}  cloudlets:0.key.organization=TDG  deployclientcount=1  deployintervalcount=2  minactiveinstances=1  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      name=${recv_name}  app-org=${developer}  region=${region}  cloudlets:0.key.organization=TDG  deployclientcount=1  deployintervalcount=2  minactiveinstances=1  maxinstances=2  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet
      name=${recv_name}  app-org=${developer}  region=${region}  cloudlets:0.key.organization=TDG  deployclientcount=1  deployintervalcount=2  minactiveinstances=1  maxinstances=2  undeployclientcount=2  undeployintervalcount=1  cloudlets:0.key.name=automationBonnCloudlet  cloudlets:1.key.organization=TDG  cloudlets:1.key.name=automationDusseldorfCloudlet

*** Keywords ***
Setup
   ${recv_name}=  get default autoprov policy name
   Set Suite Variable  ${recv_name}

Success Create/Show/Delete Auto Prov Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  autoprovpolicy create region=${region} ${parmss}
   ${show}=  Run mcctl  autoprovpolicy show region=${region} ${parmss}
   Run mcctl  autoprovpolicy delete region=${region} ${parmss}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['app-org']}

   Run Keyword If  'cloudlets:0.key.organization' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][0]['key']['organization']}  ${parms['cloudlets:0.key.organization']}
   Run Keyword If  'cloudlets:0.key.name' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][0]['key']['name']}  ${parms['cloudlets:0.key.name']}

   Run Keyword If  'cloudlets:1.key.organization' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][1]['key']['organization']}  ${parms['cloudlets:1.key.organization']}
   Run Keyword If  'cloudlets:1.key.name' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][1]['key']['name']}  ${parms['cloudlets:1.key.name']}

Update Setup
   Run mcctl  autoprovpolicy create region=${region} name=${recv_name} app-org=${developer} deployclientcount=1

Update Teardown
   Run mcctl  autoprovpolicy delete region=${region} name=${recv_name} app-org=${developer}

Success Update/Show Privacy Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  autoprovpolicy update app-org=${developer} region=${region} ${parmss}
   ${show}=  Run mcctl  autoprovpolicy show app-org=${developer} region=${region} ${parmss}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['app-org']}

   Run Keyword If  'cloudlets:0.key.organization' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][0]['key']['organization']}  ${parms['cloudlets:0.key.organization']}
   Run Keyword If  'cloudlets:0.key.name' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][0]['key']['name']}  ${parms['cloudlets:0.key.name']}

   Run Keyword If  'cloudlets:1.key.organization' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][1]['key']['organization']}  ${parms['cloudlets:1.key.organization']}
   Run Keyword If  'cloudlets:1.key.name' in ${parms}  Should Be Equal  ${show[0]['cloudlets'][1]['key']['name']}  ${parms['cloudlets:1.key.name']}


Fail Create Auto Provisioning Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  autoprovpolicy create region=${region} ${parmss}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
