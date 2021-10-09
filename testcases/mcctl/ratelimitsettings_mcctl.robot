*** Settings ***
Documentation  ratelimitsettings mcctl

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
# ECQ-3707
ratelimitsettings - mcctl shall be able to create/show/delete flow
   [Documentation]
   ...  - send ratelimitsettings create/show/delete flow via mcctl with various parms
   ...  - verify flow is created/shown/deleted

   [Template]  Success Create/Show/Delete Flow Via mcctl
  
      flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser      flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5
      flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser      flowalgorithm=TokenBucketAlgorithm  reqspersecond=5  burstsize=2
      flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests  flowalgorithm=TokenBucketAlgorithm  reqspersecond=5  burstsize=2
      flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests  flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5
      flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerIp        flowalgorithm=TokenBucketAlgorithm  reqspersecond=5  burstsize=2
      flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerIp        flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5

# ECQ-3708
ratelimitsettings - mcctl shall be able to create/show/delete maxreqs
   [Documentation]
   ...  - send ratelimitsettings create/show/delete maxreqs via mcctl with various parms
   ...  - verify flow is created/shown/deleted

   [Template]  Success Create/Show/Delete MaxReqs Via mcctl

      maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerIp        maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=2s
      maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser      maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=2s

# ECQ-3709
ratelimitsettings - mcctl shall handle flow create failures
   [Documentation]
   ...  - send ratelimitsettings createflow via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Flow Via mcctl
      # removed the args since they comeback in different order
      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  flowsettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme 
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests  flowalgorithm=TokenBucketAlgorithm 
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests  reqspersecond=5  
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests  reqspersecond=5  burstsize=1

      Error: Bad Request (400), Invalid BurstSize 0, must be greater than 0  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=AllRequests  flowalgorithm=TokenBucketAlgorithm  reqspersecond=5

      Error: parsing arg "reqspersecond\=x" failed: unable to parse "x" as float64: invalid syntax  flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  flowalgorithm=TokenBucketAlgorithm  reqspersecond=x
      Error: parsing arg "burstsize\=x" failed: unable to parse "x" as int: invalid syntax      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  reqspersecond=5  burstsize=x

# ECQ-3710
ratelimitsettings - mcctl shall handle maxreqs create failures
   [Documentation]
   ...  - send ratelimitsettings createmaxreqs via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Maxreqs Via mcctl
      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  maxreqssettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser  maxreqsalgorithm=FixedWindowAlgorithm
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme  ratelimittarget=PerUser      maxreqsalgorithm=FixedWindowAlgorithm  interval=2s

      Error: parsing arg "maxrequests\=x" failed: unable to parse "x" as int  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=x
      Error: parsing arg "interval\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxrequests=5  interval=x

# ECQ-3711
ratelimitsettings - mcctl shall handle update flow
   [Documentation]
   ...  - send ratelimitsettings updateflow via mcctl with various args
   ...  - verify flow is updated

   [Setup]  Update Flow Setup
   [Teardown]  Update Flow Teardown

   [Template]  Success Update/Show Flow Via mcctl

      flowsettingsname=${flow_name}   apiname=xx  ratelimittarget=AllRequests  apiendpointtype=Dme  flowalgorithm=TokenBucketAlgorithm
      flowsettingsname=${flow_name}2  apiname=xx  ratelimittarget=AllRequests  apiendpointtype=Dme  flowalgorithm=LeakyBucketAlgorithm  reqspersecond=100

# ECQ-3712
ratelimitsettings - mcctl shall be able to update maxreqs
   [Documentation]
   ...  - send ratelimitsettings update maxreqs via mcctl with various parms
   ...  - verify flow is created/shown/deleted

   [Setup]  Update Maxreqs Setup
   [Teardown]  Update Maxreqs Teardown

   [Template]  Success Update/Show MaxReqs Via mcctl

      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  apiendpointtype=Dme  interval=20s
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  apiendpointtype=Dme  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=15  interval=2m0s

# ECQ-3713
ratelimitsettings - mcctl shall handle update flow failures
   [Documentation]
   ...  - send ratelimitsettings updateflow via mcctl with various error cases
   ...  - verify proper error is received

   [Setup]  Update Flow Setup
   [Teardown]  Update Flow Teardown

   [Template]  Fail Update Flow Via mcctl

      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  flowsettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme

      Error: parsing arg "reqspersecond\=x" failed: unable to parse "x" as float64: invalid syntax  flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  flowalgorithm=TokenBucketAlgorithm  reqspersecond=x
      Error: parsing arg "burstsize\=x" failed: unable to parse "x" as int: invalid syntax      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  reqspersecond=5  burstsize=x

# ECQ-3714
ratelimitsettings - mcctl shall handle maxreqs update failures
   [Documentation]
   ...  - send ratelimitsettings updatemaxreqs via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Update Maxreqs Via mcctl
      # missing values
      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  maxreqssettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  apiendpointtype=Dme

      Error: parsing arg "maxrequests\=x" failed: unable to parse "x" as int  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=x
      Error: parsing arg "interval\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxrequests=5  interval=x

*** Keywords ***
Setup
   ${flow_name}=  Get Default Rate Limiting Flow Name
   Set Suite Variable  ${flow_name}

Success Create/Show/Delete Flow Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettings createflow region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  ratelimitsettings showflow region=${region} ${parmss}  version=${version}
   Run mcctl  ratelimitsettings deleteflow region=${region} ${parmss}  version=${version}

   Verify Flow  ${show}  &{parms}

Success Create/Show/Delete MaxReqs Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettings createmaxreqs region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  ratelimitsettings showmaxreqs region=${region} ${parmss}  version=${version}
   Run mcctl  ratelimitsettings deletemaxreqs region=${region} ${parmss}  version=${version}

   Should Be Equal  ${show[0]['key']['rate_limit_key']['api_name']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['key']['max_reqs_settings_name']}  ${parms['maxreqssettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  3
   END

   IF  'interval' in ${parms}
      Should Be Equal  ${show[0]['settings']['interval']}  ${parms['interval']}
   ELSE
      Should Be Equal  ${show[0]['settings']['interval']}  0s
   END

   IF  'maxrequests' in ${parms}
      Should Be Equal As Numbers   ${show[0]['settings']['max_requests']}  ${parms['maxrequests']}
   ELSE
      Should Be Equal As Numbers   ${show[0]['settings']['max_requests']}  0
   END

   IF  'maxreqsalgorithm' in ${parms}
      IF  '${parms['maxreqsalgorithm']}' == 'FixedWindowAlgorithm'
         Should Be Equal As Numbers   ${show[0]['settings']['max_reqs_algorithm']}  1
      END
   ELSE
      Should Be Equal As Numbers   ${show[0]['settings']['max_reqs_algorithm']}  0
   END

Fail Create Flow Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettings createflow region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Create Maxreqs Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettings createmaxreqs region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Update Flow Setup
   Run mcctl  ratelimitsettings createflow region=${region} flowsettingsname=${flow_name} apiname=xx apiendpointtype=Dme ratelimittarget=AllRequests flowalgorithm=TokenBucketAlgorithm reqspersecond=5 burstsize=2    version=${version}
   Run mcctl  ratelimitsettings createflow region=${region} flowsettingsname=${flow_name}2 apiname=xx apiendpointtype=Dme ratelimittarget=AllRequests flowalgorithm=LeakyBucketAlgorithm reqspersecond=5     version=${version}

Update Flow Teardown
   Run mcctl  ratelimitsettings deleteflow region=${region} flowsettingsname=${flow_name} apiname=xx apiendpointtype=Dme ratelimittarget=AllRequests flowalgorithm=TokenBucketAlgorithm reqspersecond=5 burstsize=2    version=${version}
   Run mcctl  ratelimitsettings deleteflow region=${region} flowsettingsname=${flow_name}2 apiname=xx apiendpointtype=Dme ratelimittarget=AllRequests flowalgorithm=LeakyBucketAlgorithm reqspersecond=5    version=${version}

Update Maxreqs Setup
   Run mcctl  ratelimitsettings createmaxreqs region=${region} maxreqssettingsname=${flow_name} apiname=xx apiendpointtype=Dme ratelimittarget=AllRequests maxreqsalgorithm=FixedWindowAlgorithm maxrequests=1 interval=1s  version=${version}

Update Maxreqs Teardown
   Run mcctl  ratelimitsettings deletemaxreqs region=${region} maxreqssettingsname=${flow_name} apiname=xx apiendpointtype=Dme ratelimittarget=AllRequests maxreqsalgorithm=FixedWindowAlgorithm maxrequests=1 interval=1s  version=${version}

Success Update/Show Flow Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettings updateflow region=${region} ${parmss}    version=${version}
   ${show}=  Run mcctl  ratelimitsettings showflow region=${region} ${parmss}    version=${version}

   Verify Flow  ${show}  &{parms}

Success Update/Show Maxreqs Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettings updatemaxreqs region=${region} ${parmss}    version=${version}
   ${show}=  Run mcctl  ratelimitsettings showmaxreqs region=${region} ${parmss}    version=${version}

   Should Be Equal  ${show[0]['key']['rate_limit_key']['api_name']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['key']['max_reqs_settings_name']}  ${parms['maxreqssettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  3
   END

   IF  'interval' in ${parms}
      Should Be Equal  ${show[0]['settings']['interval']}  ${parms['interval']}
   END

   IF  'maxrequests' in ${parms}
      Should Be Equal As Numbers   ${show[0]['settings']['max_requests']}  ${parms['maxrequests']}
   END

   IF  'maxreqsalgorithm' in ${parms}
      Should Be Equal As Numbers   ${show[0]['settings']['max_reqs_algorithm']}  1
   END
 
Fail Update Flow Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettings updateflow region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Update Maxreqs Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettings updatemaxreqs region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Verify Flow
   [Arguments]  ${show}  &{parms}

   Should Be Equal  ${show[0]['key']['rate_limit_key']['api_name']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['key']['flow_settings_name']}  ${parms['flowsettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['rate_limit_target']}  3
   END

   IF  'burstsize' in ${parms}
      Should Be Equal As Numbers   ${show[0]['settings']['burst_size']}  ${parms['burstsize']}
   #ELSE
   #   Should Be Equal As Numbers   ${show[0]['key']['rate_limit_key']['burstSize']}  0
   END

   IF  'reqspersecond' in ${parms}
      Should Be Equal As Numbers   ${show[0]['settings']['reqs_per_second']}  ${parms['reqspersecond']}
   #ELSE
   #   Should Be Equal As Numbers   ${show[0]['ReqsPerSecond']}  0
   END

   IF  'flowalgorithm' in ${parms}
      IF  '${parms['flowalgorithm']}' == 'TokenBucketAlgorithm'
         Should Be Equal As Numbers   ${show[0]['settings']['flow_algorithm']}  1
      ELSE
         Should Be Equal As Numbers   ${show[0]['settings']['flow_algorithm']}  2
      END
   ELSE
      Should Be Equal As Numbers   ${show[0]['settings']['flow_algorithm']}  0
   END

