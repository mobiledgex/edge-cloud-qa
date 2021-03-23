*** Settings ***
Documentation  RunCommand mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${developer}=  ${developer_org_name_automation}

*** Test Cases ***
# ECQ-2892
RunCommand - mcctl shall be able to run command on app 
   [Documentation]
   ...  - send RunCommand via mcctl with various parms
   ...  - verify command is successful

   [Template]  Success RunCommand Via mcctl
      #appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  cluster-org=MobiledgeX  command=whoami
      appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  cluster-org=MobiledgeX  command=whoami  containerid=x
      appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  cluster-org=MobiledgeX  command=whoami

# ECQ-2893
RunCommand - mcctl shall handle failures
   [Documentation]
   ...  - send RunCommand via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail RunCommand Via mcctl
      # missing values
      Error: missing required args:  ${Empty} 
      Error: missing required args:  appname=automation_api_app
      Error: missing required args:  appname=automation_api_app  app-org=${developer}
      Error: missing required args:  appname=automation_api_app  app-org=${developer}  appvers=1.0
      Error: missing required args:  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1
      Error: missing required args:  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus
      Error: missing required args:  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation
      Bad Request (400), App key {"organization":"${developer}","name":"utomation_api_app","version":"1.0"} not found  appname=utomation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  command=whoami
      Bad Request (400), App key {"organization":"obiledgeX","name":"automation_api_app","version":"1.0"} not found  appname=automation_api_app  app-org=obiledgeX  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  command=whoami
      Bad Request (400), App key {"organization":"${developer}","name":"automation_api_app","version":"111.0"} not found  appname=automation_api_app  app-org=${developer}  appvers=111.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  command=whoami
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"organization":"dmuus","name":"mocloud-1"},"organization":"${developer}"}} not found  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=mocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  command=whoami
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"organization":"tmu","name":"tmocloud-1"},"organization":"${developer}"}} not found  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=tmu  cluster=autoclusterautomation  command=whoami
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"utoclusterautomation"},"cloudlet_key":{"organization":"dmuus","name":"tmocloud-1"},"organization":"${developer}"}} not found  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=utoclusterautomation  command=whoami
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"organization":"dmuus","name":"tmocloud-1"},"organization":"obiledgeX"}} not found  appname=automation_api_app  app-org=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudlet-org=dmuus  cluster=autoclusterautomation  cluster-org=obiledgeX  command=whoami

*** Keywords ***
Success RunCommand Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
 
   ${out}=  Run mcctl  runcommand region=${region} ${parmss} --debug 
   @{outsplit}=  Split To Lines  ${out}
   Should Be Equal  ${outsplit[1]}  root

Fail RunCommand Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  runcommand region=${region} ${parmss}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
