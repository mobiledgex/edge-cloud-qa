*** Settings ***
Documentation  RunDebug mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown   Cleanup Provisioning

Test Timeout  2m

*** Variables ***

${cloudlet_name_openstack}=  automationHamburgCloudlet
${cloudlet_name_openstack_shared}=  automationHamburgCloudlet 
${cloudlet_name_openstack_dedicated}=  automationHamburgCloudlet
${operator_name_openstack}=  TDG
${cloudlet_name_vsphere}=  DFWVMW2
${region_US}=  US
${region}=  EU
${developer}=  MobiledgeX
${type_shep}=  shepherd
${type_crm}=  crm
${type_notifyroot}=  notifyroot
${timeout}=  45s
${pool_name}=  mcctlpool
${cpoc}=  cpoc

# mcctl --addr https://console-qa.mobiledgex.net region RunDebug cmd=
# Error: Bad Request (400), No cmd specified


*** Test Cases ***

# ECQ-2868
RunDebug - mcctl shall handle cmd with no key value or cmd
   [Documentation]
   ...  - send RunDebug with no cmd specified
   ...  - verify proper error is displayed
   ...  - send RunDebug without cmd
   ...  - verify error for required args is returned

   [Template]  Fail RunDebug Command Via mcctl

      Error: Bad Request (400)  No cmd specified  cloudlet=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}  type=crm  cmd=  args=ls
      Error: missing required args: cmd  failed:Error: missing required arg  cloudlet=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}  type=crm  

# ECQ-2869
RunDebug - mcctl shall handle cmd without val format
   [Documentation]
   ...  - send RunDebug cmd via mcctl with incorrect val format
   ...  - verify proper error is received

   ${no_cmd}=  Run Keyword and Expect Error  *  Run mcctl  region RunDebug
   Should Contain Any  ${no_cmd}  missing required args: cmd  Error: missing required args: cmd

   ${cmd_format}=  Run Keyword and Expect Error  *  Run mcctl  region RunDebug cmd
   Should Contain Any  ${cmd_format}  Error: arg  val format  



# ECQ-2870 
RunDebug - mcctl shall handle cmd unknown and timeout error
   [Documentation]
   ...  - send RunDebug args via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Check Output For Unknown Cmd
      cmds are crmcmd  cloudlet=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}  type=crm  cmd=ccrmcmd
      cmds are crmcmd  cloudlet=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}  type=crm  cmd=.  args=ls
      cmds are crmcmd  request timed out  cloudlet=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}  type=crm  cmd=xxxxx  timeout=1ms
      cmds are crmcmd  request timed out  cloudlet=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}  type=crm  cmd=ebable-logs

#ECQ-2871
RunDebug - mcctl shall send available commands to node type shepherd
   [Documentation]
   ...  - send all RunDebug cmd to node type shepherd 
   ...  - verify cmd performs action on node

   [Template]  Check Output For All Known Cmd Node Shepherd
      now api  disabled debug levels              cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=disable-debug-levels timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=stop-cpu-profile timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=stop-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=start-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=start-cpu-profile timeout=${timeout}
      api,notify  api,notify,infra  api           cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=show-debug-levels timeout=${timeout}
      triggered refresh                           cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=refresh-internal-certs timeout=${timeout}
      H4sIAAAAAAAE                                cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=get-mem-profile timeout=${timeout}
      enabled log sampling  request timed out     cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=enable-sample-logging timeout=${timeout}
      enabled debug levels                        cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=enable-debug-levels timeout=${timeout}
      disabled log sampling                       cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=disable-sample-logging timeout=${timeout}
      disabled debug levels                       cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=shepherd  cmd=disable-debug-levels timeout=${timeout}
      ${mcctlautomationpool}                      cloudlet=${cloudlet_name_vsphere}              region=${region_US}  type=shepherd  cmd=dump-cloudlet-pools timeout=${timeout}   


#ECQ-2872
RunDebug - mcctl shall send available commands to node type crm
   [Documentation]
   ...  - send all RunDebug cmd to node type crm
   ...  - verify cmd performs action on node

   [Template]  Check Output For All Known Cmd Node Crm
      now api  disabled debug levels              cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=disable-debug-levels timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=stop-cpu-profile timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=stop-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=start-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=start-cpu-profile timeout=${timeout}
      api,notify  api,notify,infra  api           cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=show-debug-levels timeout=${timeout}
      triggered refresh                           cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=refresh-internal-certs timeout=${timeout}
      H4sIAAAAAAAE                                cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=get-mem-profile timeout=${timeout}
      enabled log sampling  request timed out     cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=enable-sample-logging timeout=${timeout}
      enabled debug levels                        cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=enable-debug-levels timeout=${timeout}
      disabled log sampling                       cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=disable-sample-logging timeout=${timeout}
      disabled debug levels                       cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  type=crm  cmd=disable-debug-levels timeout=${timeout}
      ${mcctlautomationpool}                      cloudlet=${cloudlet_name_vsphere}              region=${region_US}  type=crm  cmd=dump-cloudlet-pools timeout=${timeout}

# ECQ-2873
RunDebug - mcctl shall send available commands to any node type or region 
   [Documentation]
   ...  - send all RunDebug cmd to all node types 
   ...  - verify cmd performs action on node

   [Template]  Check Output For All Known Cmd Node All
#region speficied with cmd

      now api  disabled debug levels              cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=disable-debug-levels timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=stop-cpu-profile timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=stop-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=start-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=start-cpu-profile timeout=${timeout}
      api,notify  api,notify,infra  api           cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=show-debug-levels timeout=${timeout}
      triggered refresh                           cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=refresh-internal-certs timeout=${timeout}
      H4sIAAAAAAAE                                cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=get-mem-profile timeout=${timeout}
      enabled log sampling  request timed out     cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=enable-sample-logging timeout=${timeout}
      enabled debug levels                        cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=enable-debug-levels timeout=${timeout}
      disabled log sampling                       cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=disable-sample-logging timeout=${timeout}
      disabled debug levels                       cloudlet=${cloudlet_name_openstack_dedicated}  region=${region}  cmd=disable-debug-levels timeout=${timeout}
      ${mcctlautomationpool}                      cloudlet=${cloudlet_name_vsphere}              region=${region_US}  cmd=dump-cloudlet-pools timeout=${timeout}

#no region specified only cmd

      now api  disabled debug levels              cloudlet=${cloudlet_name_openstack_dedicated}  cmd=disable-debug-levels timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  cmd=stop-cpu-profile timeout=${timeout}
      no cpu profiling in progress  H4sIAAAAAAAE  cloudlet=${cloudlet_name_openstack_dedicated}  cmd=stop-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  cmd=start-cpu-profile timeout=${timeout}
      cpu profiling already in progress  started  cloudlet=${cloudlet_name_openstack_dedicated}  cmd=start-cpu-profile timeout=${timeout}
      api,notify  api,notify,infra  api           cloudlet=${cloudlet_name_openstack_dedicated}  cmd=show-debug-levels timeout=${timeout}
      triggered refresh                           cloudlet=${cloudlet_name_openstack_dedicated}  cmd=refresh-internal-certs timeout=${timeout}
      H4sIAAAAAAAE                                cloudlet=${cloudlet_name_openstack_dedicated}  cmd=get-mem-profile timeout=${timeout}
      enabled log sampling  request timed out     cloudlet=${cloudlet_name_openstack_dedicated}  cmd=enable-sample-logging timeout=${timeout}
      enabled debug levels                        cloudlet=${cloudlet_name_openstack_dedicated}  cmd=enable-debug-levels timeout=${timeout}
      disabled log sampling                       cloudlet=${cloudlet_name_openstack_dedicated}  cmd=disable-sample-logging timeout=${timeout}
      disabled debug levels                       cloudlet=${cloudlet_name_openstack_dedicated}  cmd=disable-debug-levels timeout=${timeout}
      ${mcctlautomationpool}                      cloudlet=${cloudlet_name_vsphere}              cmd=dump-cloudlet-pools timeout=${timeout}

#ECQ-2874
RunDebug - mcctl shall send available commands to every cloudlet region and node
   [Documentation]
   ...  - send all RunDebug cmd to everything
   ...  - verify cmd performs action on all nodes

   [Template]  Check Output For All Known Cmd Cloudlet All

#Sends to all cloudlets and node types no region or cloudlet specified. Lists will count the ruturns since no determined number of cloudlets is known.

      crm  shepherd  cpu profiling already in progress  started. output will be base64 encoded go tool pprof file contents         cmd=start-cpu-profile timeout=${timeout}
      crm  shepherd  cpu profiling already in progress  started. output will be base64 encoded go tool pprof file contents         cmd=start-cpu-profile timeout=${timeout}
      crm  shepherd  triggered refresh  unknown                                                                                    cmd=refresh-internal-certs timeout=${timeout}
      crm  shepherd  disabled debug levels, now api,notify,infra,info  disabled debug levels, now api,notify,infra,metrics         cmd=disable-debug-levels timeout=${timeout}
      crm  shepherd  api,notify,infra,info  api,notify,infra,metrics                                                               cmd=show-debug-levels timeout=${timeout}
      crm  shepherd  enabled debug levels, now api,notify,infra,info  enabled debug levels, now api,notify,infra,metrics           cmd=enable-debug-levels timeout=${timeout}
      crm  shepherd  enabled log sampling  not needed                                                                              cmd=enable-sample-logging timeout=${timeout}
      crm  shepherd  disabled log sampling  not needed                                                                             cmd=disable-sample-logging timeout=${timeout}
#dump-cloudlet-pools
      crm  shepherd  dump-cloudlet-pools  ${mcctlautomationpool}                                                              cmd=dump-cloudlet-pools timeout=${timeout}


#note this test is huge and pulls down about 40 mem profiles from nodes to count. If looking at the log in a browser it will take about a minute to expand the run mccttl or get match count
#      crm  shepherd  H4sIAAAAAAAE*  no cpu profiling in progress                                                                   cmd=get-mem-profile timeout=${timeout}
#      crm  shepherd  no cpu profiling in progress  H4sIAAAAAAAE*                                                                   cmd=stop-cpu-profile timeout=${timeout}

# Size with tests. If the profile test is left in the return will be 100MB for the log these two tests pass but should not be run daily
# -rw-r--r--@ 1 thomasdunkle  staff   100M Nov 22 13:13 log.htmli
# -rw-r--r--  1 thomasdunkle  staff   101M Nov 22 13:13 output.xml

#Size without those two profile tests is reducded by 98M
#-rw-r--r--@ 1 thomasdunkle  staff   2.4M Nov 22 13:27 log.html
#-rw-r--r--  1 thomasdunkle  staff   3.4M Nov 22 13:27 output.xml



*** Keywords ***
Cleanup Provisioning
   Log to Console  \nCleaning up CloudletPool ${mcctlautomationpool} 
   Run mcctl  region DeleteCloudletPool region=US cloudlets=DFWVMW2 name=${mcctlautomationpool} org=packet
   MexMasterController.Cleanup Provisioning

Setup
   ${epoch}=  Get Time  epoch
   ${mcctlautomationpool}=  Catenate  ${cpoc}${epoch}${pool_name}
   Set Suite Variable  ${mcctlautomationpool} 
   Run mcctl  region CreateCloudletPool region=US cloudlets=DFWVMW2 name=${mcctlautomationpool} org=packet
   

Check Output For All Known Cmd Node Shepherd
   [Arguments]  ${output_msg}  ${output_msg2}=Unknown  ${output_msg3}=cmds are  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run mcctl  region RunDebug ${parmss}
   Should Contain Any  ${std_output}[0][node][type]  ${type_shep}
   Should Contain Any  ${std_output}[0][output]  ${output_msg}  ${output_msg2}  ${output_msg3}

Check Output For All Known Cmd Node Crm
   [Arguments]  ${output_msg}  ${output_msg2}=Unknown  ${output_msg3}=cmds are  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run mcctl  region RunDebug ${parmss}
   Should Contain Any  ${std_output}[0][node][type]  ${type_crm}
   Should Contain Any  ${std_output}[0][output]  ${output_msg}  ${output_msg2}  ${output_msg3}

Check Output For All Known Cmd Node All
   [Arguments]  ${output_msg}  ${output_msg2}=Unknown  ${output_msg3}=cmds are  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run mcctl  region RunDebug ${parmss}
   Should Contain Any  ${std_output}[0][node][type]  ${type_crm}  ${type_shep}    
   Should Contain Any  ${std_output}[1][node][type]  ${type_crm}  ${type_shep}  
   Should Contain Any  ${std_output}[0][output]  ${output_msg}  ${output_msg2}  ${output_msg3}
   Should Contain Any  ${std_output}[1][output]  ${output_msg}  ${output_msg2}  ${output_msg3}

Check Output For All Known Cmd Cloudlet All
   [Arguments]  ${ntype}  ${ntype2}  ${output}  ${output2}  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())


   ${sample}=  Run mcctl  region RunDebug ${parmss}
   ${cnt}=  Get Length  ${sample}
         @{Enabled}=  Create List  #${output}
         @{Node_Type}=  Create List  #${ntype}
       FOR  ${key}  IN RANGE  ${cnt}
         Run Keyword And Ignore Error  Append To List    ${Enabled}      ${sample}[${key}][output]
         Append To List    ${Node_Type}    ${sample}[${key}][node][type]
       END
         Log List  ${Enabled}
         Log List  ${Node_Type}
         ${count_ntype}       Get Match Count   ${Node_Type}   ${ntype}
         ${count_ntype2}      Get Match Count   ${Node_Type}   ${ntype2}
         ${passvalue}=  Set Variable  ${cnt} / 3
         Should Be True  ${passvalue} < ${count_ntype}+${count_ntype2}


Check Output For Unknown Cmd
   [Arguments]  ${error_msg}  ${error_msg2}=Unknown cmd  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run mcctl  region RunDebug ${parmss}
   Should Contain Any  ${std_output}[0][output]  ${error_msg}  ${error_msg2}

Fail RunDebug Command Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_output}=  Run Keyword and Expect Error  *  Run mcctl  region RunDebug ${parmss}
   Should Contain Any  ${std_output}  ${error_msg}  ${error_msg2}


