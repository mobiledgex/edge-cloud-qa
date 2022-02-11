*** Settings ***
Documentation  ShowLogs mcctl

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
# ECQ-2894
ShowLogs - mcctl shall be able to show logs on app 
   [Documentation]
   ...  - send ShowLogs via mcctl with various parms
   ...  - verify command is successful

   [Template]  Success ShowLogs Via mcctl
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  containerid=x
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  since=1985-04-12T23:20:50.52Z
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  since=1m
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  since=1s
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  since=1h
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  timestamps=true
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  timestamps=1
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  timestamps=false
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  timestamps=0
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  tail=1
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  follow=true
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  follow=1
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  follow=false
      appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  follow=0

# ECQ-2895
ShowLogs - mcctl shall handle failures
   [Documentation]
   ...  - send ShowLogs via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail ShowLogs Via mcctl
      # missing values
      Error: missing required args:  ${Empty} 
      Error: missing required args:  appname=automation_api_app
      Error: missing required args:  appname=automation_api_app  apporg=MobiledgeX
      Error: missing required args:  appname=automation_api_app  apporg=MobiledgeX  appvers=1.0
      Error: missing required args:  appname=automation_api_app  apporg=MobiledgeX  appvers=1.0  cloudlet=tmocloud-1
      Error: missing required args:  appname=automation_api_app  apporg=MobiledgeX  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus
      Bad Request (400), App key {"organization":"${developer}","name":"utomation_api_app","version":"1.0"} not found  appname=utomation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation
      Bad Request (400), App key {"organization":"obiledgeX","name":"automation_api_app","version":"1.0"} not found  appname=automation_api_app  apporg=obiledgeX  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation
      Bad Request (400), App key {"organization":"${developer}","name":"automation_api_app","version":"111.0"} not found  appname=automation_api_app  apporg=${developer}  appvers=111.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"organization":"tmus","name":"mocloud-1"},"organization":"MobiledgeX"}} not found  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=mocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"organization":"tmu","name":"tmocloud-1"},"organization":"MobiledgeX"}} not found  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmu  cluster=autoclusterautomation  clusterorg=MobiledgeX
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"utoclusterautomation"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-1"},"organization":"MobiledgeX"}} not found  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=utoclusterautomation  clusterorg=MobiledgeX
      Error: Bad Request (400), AppInst key {"app_key":{"organization":"${developer}","name":"automation_api_app","version":"1.0"},"cluster_inst_key":{"cluster_key":{"name":"autoclusterautomation"},"cloudlet_key":{"organization":"tmus","name":"tmocloud-1"},"organization":"obiledgeX"}} not found  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=obiledgeX 

      # bad values
      Error: Bad Request (400), Unable to parse Since field as duration or RFC3339 formatted time  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  since=1985
      Error: Bad Request (400), Unable to parse Since field as duration or RFC3339 formatted time  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  since=1d
      Error: parsing arg "timestamps\=s" failed: unable to parse "s" as bool: invalid syntax, valid values are true, false  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  timestamps=s
      Error: parsing arg "timestamps\=2" failed: unable to parse "2" as bool: invalid syntax, valid values are true, false  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  timestamps=2
      Error: parsing arg "tail\=s" failed: unable to parse "s" as int: invalid syntax  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  tail=s
      Error: parsing arg "follow\=s" failed: unable to parse "s" as bool: invalid syntax, valid values are true, false  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  follow=s
      Error: parsing arg "follow\=2" failed: unable to parse "2" as bool: invalid syntax, valid values are true, false  appname=automation_api_app  apporg=${developer}  appvers=1.0  cloudlet=tmocloud-1  cloudletorg=tmus  cluster=autoclusterautomation  clusterorg=MobiledgeX  follow=2



*** Keywords ***
Success ShowLogs Via mcctl
   [Arguments]  &{parms}
   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
 
   ${out}=  Run mcctl  showlogs region=${region} ${parmss} --debug 
   @{outsplit}=  Split To Lines  ${out}
   Should Be Equal  ${outsplit[1]}  here's some logs

Fail ShowLogs Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  showlogs region=${region} ${parmss}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
