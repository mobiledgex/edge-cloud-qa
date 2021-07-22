*** Settings ***
Documentation  CreateAutoScalePolicy mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  10m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${version}=  latest

*** Test Cases ***
CreateAutoScalePolicy - mcctl shall be able to create/show/delete policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/ShowAutoScalePolicy/DeleteAutoScalePolicy via mcctl with various parms
   ...  - verify policy is created/shown/deleted

   [Template]  Success Create/Show/Delete Autoscale Policy Via mcctl
   
      name=${recv_name}  cluster-org=${developer}  minnodes=1  maxnodes=4  scaleupcputhresh=80  scaledowncputhresh=30  triggertimesec=300
      name=${recv_name}  cluster-org=${developer}  minnodes=1  maxnodes=4  scaleupcputhresh=80
      name=${recv_name}  cluster-org=${developer}  minnodes=1  maxnodes=4  scaleupcputhresh=80  triggertimesec=300
      name=${recv_name}  cluster-org=${developer}  minnodes=1  maxnodes=4  scaleupcputhresh=80  scaledowncputhresh=30

CreateAutoScalePolicy - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateAutoScalePolicy via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Autoscale Policy Via mcctl
      # missing values

      # removed the args since they comeback in different order
      Error: missing required args:    #cluster-org name minnodes maxnodes   #not sending any args with mcctl
      Error: missing required args:  cluster-org=${developer}
      Error: missing required args:  cluster-org=${developer}  name=${recv_name}
      Error: missing required args: maxnodes  cluster-org=${developer}  name=${recv_name}  minnodes=1
      Error: Bad Request (400), Max nodes must be greater than Min nodes  cluster-org=${developer}  name=${recv_name}  minnodes=2  maxnodes=1  scaleupcputhresh=50  scaledowncputhresh=10
      Error: Bad Request (400), One of target cpu or target mem or target active connections must be specified  cluster-org=${developer}  name=${recv_name}  minnodes=1  maxnodes=2
      Error: Bad Request (400), Scale down cpu threshold must be less than scale up cpu threshold  cluster-org=${developer}  name=${recv_name}  minnodes=1  maxnodes=2  scaleupcputhresh=50  scaledowncputhresh=50
      Error: Bad Request (400), Scale down cpu threshold must be less than scale up cpu threshold  cluster-org=${developer}  name=${recv_name}  minnodes=1  maxnodes=2  scaledowncputhresh=50

      # invalid values
      Error: Bad Request (400), Scale down CPU threshold must be between 0 and 100  cluster-org=${developer}  name=${recv_name}  minnodes=1  maxnodes=2  scaleupcputhresh=50  scaledowncputhresh=101
      Error: Bad Request (400), Scale up CPU threshold must be between 0 and 100  cluster-org=${developer}  name=${recv_name}  minnodes=1  maxnodes=2  scaleupcputhresh=101  scaledowncputhresh=50
      Error: parsing arg "triggertimesec\=9999999999" failed: unable to parse "9999999999" as uint: value out of range  cluster-org=${developer}  name=${recv_name}  minnodes=1  maxnodes=2  scaleupcputhresh=80  scaledowncputhresh=50  triggertimesec=9999999999
      Error: Bad Request (400), Org Mobiledge not found  cluster-org=Mobiledge  name=${recv_name}  minnodes=1  maxnodes=2  scaleupcputhresh=80  scaledowncputhresh=50

UpdateAutoScalePolicy - mcctl shall handle update policy
   [Documentation]
   ...  - send UpdateAutoScalePolicy via mcctl with various args
   ...  - verify policy is updated

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Success Update/Show Autoscale Policy Via mcctl

      name=${recv_name}  cluster-org=${developer}  minnodes=2
      name=${recv_name}  cluster-org=${developer}  maxnodes=5
      name=${recv_name}  cluster-org=${developer}  minnodes=3  maxnodes=6
      name=${recv_name}  cluster-org=${developer}  scaledowncputhresh=20
      name=${recv_name}  cluster-org=${developer}  scaleupcputhresh=70
      name=${recv_name}  cluster-org=${developer}  scaledowncputhresh=25  scaleupcputhresh=75
      name=${recv_name}  cluster-org=${developer}  triggertimesec=100

UpdateAutoScalePolicy - mcctl shall handle update failures
   [Documentation]
   ...  - send UpdateAutoScalePolicy via mcctl with various error cases
   ...  - verify proper error is received

   [Setup]  Update Setup
   [Teardown]  Update Teardown

   [Template]  Fail Update Autoscale Policy Via mcctl

      Error: Bad Request (400), Max nodes must be greater than Min nodes  cluster-org=${developer}  name=${recv_name}  minnodes=4
      Error: Bad Request (400), Max nodes must be greater than Min nodes  cluster-org=${developer}  name=${recv_name}  maxnodes=1
      Error: Bad Request (400), Scale down cpu threshold must be less than scale up cpu threshold  cluster-org=${developer}  name=${recv_name}  scaleupcputhresh=40
      Error: Bad Request (400), Scale down cpu threshold must be less than scale up cpu threshold  cluster-org=${developer}  name=${recv_name}  scaledowncputhresh=80     

*** Keywords ***
Setup
   ${recv_name}=  Get Default Autoscale Policy Name
   Set Suite Variable  ${recv_name}

Success Create/Show/Delete Autoscale Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  autoscalepolicy create region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  autoscalepolicy show region=${region} ${parmss}  version=${version}
   Run mcctl  autoscalepolicy delete region=${region} ${parmss}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cluster-org']}
   Should Be Equal As Numbers   ${show[0]['min_nodes']}  ${parms['minnodes']}
   Should Be Equal As Numbers   ${show[0]['max_nodes']}  ${parms['maxnodes']}
   Run Keyword If  'scale_up_cpu_thresh' in ${parms}    Should Be Equal As Numbers   ${show[0]['scale_up_cpu_thresh']}  ${parms['scaleupcputhresh']}
   Run Keyword If  'scale_down_cpu_thresh' in ${parms}  Should Be Equal As Numbers   ${show[0]['scale_down_cpu_thresh']}  ${parms['scaledowncputhresh']}
   Run Keyword If  'trigger_time_sec' in ${parms}       Should Be Equal As Numbers   ${show[0]['trigger_time_sec']}  ${parms['triggertimesec']}

Fail Create Autoscale Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  autoscalepolicy create region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Update Setup
   Run mcctl  autoscalepolicy create region=${region} name=${recv_name} cluster-org=${developer} minnodes=1 maxnodes=4 scaleupcputhresh=80 scaledowncputhresh=40   version=${version}

Update Teardown
   Run mcctl  autoscalepolicy delete region=${region} name=${recv_name} cluster-org=${developer}    version=${version}

Success Update/Show Autoscale Policy Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  autoscalepolicy update region=${region} ${parmss}    version=${version}
   ${show}=  Run mcctl  autoscalepolicy show region=${region} ${parmss}    version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal  ${show[0]['key']['organization']}  ${parms['cluster-org']}

   Run Keyword If  'minnodes' in ${parms}  Should Be Equal As Numbers   ${show[0]['min_nodes']}  ${parms['minnodes']}
   Run Keyword If  'maxnodes' in ${parms}  Should Be Equal As Numbers   ${show[0]['max_nodes']}  ${parms['maxnodes']}
   Run Keyword If  'scaleupcputhresh' in ${parms}  Should Be Equal As Numbers  ${show[0]['scale_up_cpu_thresh']}  ${parms['scaleupcputhresh']}
   Run Keyword If  'scaledowncputhresh' in ${parms}  Should Be Equal As Numbers  ${show[0]['scale_down_cpu_thresh']}  ${parms['scaledowncputhresh']}
   Run Keyword If  'triggertimesec' in ${parms}  Should Be Equal As Numbers  ${show[0]['trigger_time_sec']}  ${parms['triggertimesec']}

Fail Update Autoscale Policy Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  autoscalepolicy update region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

