*** Settings ***
Documentation  DeleteIdleReservableClusterInsts mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${version}=  latest

*** Test Cases ***
# ECQ-3196
DeleteIdleReservableClusterInsts - mcctl shall be able to delete idle clusters
   [Documentation]
   ...  - send DeleteIdleReservableClusterInsts via mcctl with various parms
   ...  - verify delete is done

   [Tags]  ReservableCluster

   [Template]  Success DeleteIdleReservableClusterInsts Via mcctl
   
      idletime=${None}
      idletime=0
      idletime=0s
      idletime=1s
      idletime=5m
      idletime=10m40s
      idletime=4h12m
      idletime=4h12m3s

# ECQ-3197
DeleteIdleReservableClusterInsts - mcctl shall handle create failures
   [Documentation]
   ...  - send DeleteIdleReservableClusterInsts via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  ReservableCluster

   [Template]  Fail DeleteIdleReservableClusterInsts Via mcctl
      time: invalid duration "x"               idletime=x
      time: missing unit in duration "5"       idletime=5
      time: unknown unit "a" in duration "5a"  idletime=5a

*** Keywords ***
Success DeleteIdleReservableClusterInsts Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items() if val is not None) 

   ${out}=  Run mcctl  region DeleteIdleReservableClusterInsts region=${region} ${parmss}  version=${version}

   Should Be Equal As Strings  ${out}  {'message': 'Delete done'}

Fail DeleteIdleReservableClusterInsts Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  region DeleteIdleReservableClusterInsts region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}
