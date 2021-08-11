*** Settings ***
Documentation  ratelimitsettingsmc mcctl

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
# ECQ-3681
ratelimitsettingsmc - mcctl shall be able to create/show/delete flow
   [Documentation]
   ...  - send ratelimitsettingsmc create/show/delete flow via mcctl with various parms
   ...  - verify flow is created/shown/deleted

   [Template]  Success Create/Show/Delete Flow Via mcctl
  
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp        flowalgorithm=TokenBucketAlgorithm  reqspersecond=5 
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser      flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp        flowalgorithm=TokenBucketAlgorithm  reqspersecond=5  burstsize=2
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser      flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5  burstsize=2
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5  burstsize=2

# ECQ-3682
ratelimitsettingsmc - mcctl shall be able to create/show/delete maxreqs
   [Documentation]
   ...  - send ratelimitsettingsmc create/show/delete maxreqs via mcctl with various parms
   ...  - verify flow is created/shown/deleted

   [Template]  Success Create/Show/Delete MaxReqs Via mcctl

      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=2s
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp        maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=2s
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser      maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=2s

# ECQ-3683
ratelimitsettingsmc - mcctl shall handle flow create failures
   [Documentation]
   ...  - send ratelimitsettingsmc createflow via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Flow Via mcctl
      # removed the args since they comeback in different order
      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  flowsettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  flowalgorithm=LeakyBucketAlgorithm
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests 
      Error: parsing arg "reqspersecond\=x" failed: unable to parse "x" as float64: invalid syntax  flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  flowalgorithm=TokenBucketAlgorithm  reqspersecond=x
      Error: parsing arg "burstsize\=x" failed: unable to parse "x" as int: invalid syntax      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  reqspersecond=5  burstsize=x

# ECQ-3684
ratelimitsettingsmc - mcctl shall handle maxreqs create failures
   [Documentation]
   ...  - send ratelimitsettingsmc createmaxreqs via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Maxreqs Via mcctl
      # missing values
      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  maxreqssettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxreqsalgorithm=FixedWindowAlgorithm
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxreqsalgorithm=FixedWindowAlgorithm  interval=1s

      Error: parsing arg "maxrequests\=x" failed: unable to parse "x" as int  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=x
      Error: parsing arg "interval\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc        maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxrequests=5  interval=x

# ECQ-3685
ratelimitsettingsmc - mcctl shall handle update flow
   [Documentation]
   ...  - send ratelimitsettingsmc updateflow via mcctl with various args
   ...  - verify flow is updated

   [Setup]  Update Flow Setup
   [Teardown]  Update Flow Teardown

   [Template]  Success Update/Show Flow Via mcctl

      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  flowalgorithm=TokenBucketAlgorithm
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  flowalgorithm=LeakyBucketAlgorithm
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp        flowalgorithm=TokenBucketAlgorithm
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser      flowalgorithm=LeakyBucketAlgorithm
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  reqspersecond=7
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp        flowalgorithm=TokenBucketAlgorithm  reqspersecond=10
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser      flowalgorithm=LeakyBucketAlgorithm  reqspersecond=51
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  reqspersecond=5  burstsize=2
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp        flowalgorithm=TokenBucketAlgorithm  reqspersecond=5  burstsize=20
      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser      flowalgorithm=LeakyBucketAlgorithm  reqspersecond=5  burstsize=2

# ECQ-3686
ratelimitsettingsmc - mcctl shall be able to update maxreqs
   [Documentation]
   ...  - send ratelimitsettingsmc update maxreqs via mcctl with various parms
   ...  - verify flow is updated

   [Setup]  Update Maxreqs Setup
   [Teardown]  Update Maxreqs Teardown

   [Template]  Success Update/Show MaxReqs Via mcctl

      maxreqssettingsname=${flow_name}  apiname=xxy  ratelimittarget=AllRequests
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxreqsalgorithm=FixedWindowAlgorithm
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser  maxreqsalgorithm=FixedWindowAlgorithm
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxrequests=15
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=15
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=15
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxrequests=15  interval=20s
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=20s
      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerUser  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=5  interval=20s

# ECQ-3687
ratelimitsettingsmc - mcctl shall handle update flow failures
   [Documentation]
   ...  - send ratelimitsettingsmc updateflow via mcctl with various error cases
   ...  - verify proper error is received

   [Setup]  Update Flow Setup
   [Teardown]  Update Flow Teardown

   [Template]  Fail Update Flow Via mcctl

      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  flowsettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  flowsettingsname=${flow_name}  apiname=xx

      Error: parsing arg "reqspersecond\=x" failed: unable to parse "x" as float64: invalid syntax  flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  flowalgorithm=TokenBucketAlgorithm  reqspersecond=x
      Error: parsing arg "burstsize\=x" failed: unable to parse "x" as int: invalid syntax      flowsettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  reqspersecond=5  burstsize=x

# ECQ-3688
ratelimitsettingsmc - mcctl shall handle maxreqs update failures
   [Documentation]
   ...  - send ratelimitsettingsmc updatemaxreqs via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Update Maxreqs Via mcctl
      # missing values
      Error: missing required args:    #not sending any args with mcctl
      Error: missing required args:  maxreqssettingsname=${flow_name}
      Error: missing required args:  apiname=xx
      Error: missing required args:  ratelimittarget=AllRequests
      Error: missing required args:  maxreqssettingsname=${flow_name}  apiname=xx

      Error: parsing arg "maxrequests\=x" failed: unable to parse "x" as int  maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=PerIp  maxreqsalgorithm=FixedWindowAlgorithm  maxrequests=x
      Error: parsing arg "interval\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc      maxreqssettingsname=${flow_name}  apiname=xx  ratelimittarget=AllRequests  maxrequests=5  interval=x

# ECQ-3689
ratelimitsettingsmc - mcctl shall handle show flow
   [Documentation]
   ...  - send ratelimitsettingsmc show via mcctl with various args
   ...  - verify flow is shown

   [Template]  Success Show Via mcctl

      noarg=${None}
      apiname=Global
      ratelimittarget=AllRequests

*** Keywords ***
Setup
   ${flow_name}=  Get Default Rate Limiting Flow Name
   Set Suite Variable  ${flow_name}

Success Create/Show/Delete Flow Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettingsmc createflow ${parmss}  version=${version}
   ${show}=  Run mcctl  ratelimitsettingsmc showflow ${parmss}  version=${version}
   Run mcctl  ratelimitsettingsmc deleteflow ${parmss}  version=${version}

   Should Be Equal  ${show[0]['ApiName']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['FlowSettingsName']}  ${parms['flowsettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  3
   END

   IF  'burstsize' in ${parms}
      Should Be Equal As Numbers   ${show[0]['BurstSize']}  ${parms['burstsize']}
   ELSE
      Should Be Equal As Numbers   ${show[0]['BurstSize']}  0
   END

   IF  'reqspersecond' in ${parms}
      Should Be Equal As Numbers   ${show[0]['ReqsPerSecond']}  ${parms['reqspersecond']}
   ELSE
      Should Be Equal As Numbers   ${show[0]['ReqsPerSecond']}  0
   END

   IF  'flowalgorithm' in ${parms}
      IF  '${parms['flowalgorithm']}' == 'TokenBucketAlgorithm'
         Should Be Equal As Numbers   ${show[0]['FlowAlgorithm']}  1
      ELSE
         Should Be Equal As Numbers   ${show[0]['FlowAlgorithm']}  2 
      END
   ELSE
      Should Be Equal As Numbers   ${show[0]['FlowAlgorithm']}  0
   END

Success Create/Show/Delete MaxReqs Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettingsmc createmaxreqs ${parmss}  version=${version}
   ${show}=  Run mcctl  ratelimitsettingsmc showmaxreqs ${parmss}  version=${version}
   Run mcctl  ratelimitsettingsmc deletemaxreqs ${parmss}  version=${version}

   Should Be Equal  ${show[0]['ApiName']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['MaxReqsSettingsName']}  ${parms['maxreqssettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  3
   END

   IF  'interval' in ${parms}
      Should Be Equal  ${show[0]['Interval']}  ${parms['interval']}
   ELSE
      Should Be Equal  ${show[0]['Interval']}  0s
   END

   IF  'maxrequests' in ${parms}
      Should Be Equal As Numbers   ${show[0]['MaxRequests']}  ${parms['maxrequests']}
   ELSE
      Should Be Equal As Numbers   ${show[0]['MaxRequests']}  0
   END

   IF  'maxreqsalgorithm' in ${parms}
      IF  '${parms['maxreqsalgorithm']}' == 'FixedWindowAlgorithm'
         Should Be Equal As Numbers   ${show[0]['MaxReqsAlgorithm']}  1
      END
   ELSE
      Should Be Equal As Numbers   ${show[0]['MaxReqsAlgorithm']}  0
   END

Fail Create Flow Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettingsmc createflow ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Create Maxreqs Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettingsmc createmaxreqs ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Update Flow Setup
   Run mcctl  ratelimitsettingsmc createflow flowsettingsname=${flow_name} apiname=xx ratelimittarget=AllRequests flowalgorithm=TokenBucketAlgorithm reqspersecond=5   version=${version}

Update Flow Teardown
   Run mcctl  ratelimitsettingsmc deleteflow flowsettingsname=${flow_name} apiname=xx ratelimittarget=AllRequests    version=${version}

Update Maxreqs Setup
   Run mcctl  ratelimitsettingsmc createmaxreqs maxreqssettingsname=${flow_name} apiname=xx ratelimittarget=AllRequests maxreqsalgorithm=FixedWindowAlgorithm maxrequests=5 interval=2s  version=${version}

Update Maxreqs Teardown
   Run mcctl  ratelimitsettingsmc deletemaxreqs maxreqssettingsname=${flow_name} apiname=xx ratelimittarget=AllRequests    version=${version}

Success Update/Show Flow Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettingsmc updateflow ${parmss}    version=${version}
   ${show}=  Run mcctl  ratelimitsettingsmc showflow ${parmss}    version=${version}

   Verify Flow Update  ${show}  &{parms}

Success Update/Show Maxreqs Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   Run mcctl  ratelimitsettingsmc updatemaxreqs ${parmss}    version=${version}
   ${show}=  Run mcctl  ratelimitsettingsmc showmaxreqs ${parmss}    version=${version}

   Should Be Equal  ${show[0]['ApiName']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['MaxReqsSettingsName']}  ${parms['maxreqssettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  3
   END

   IF  'interval' in ${parms}
      Should Be Equal  ${show[0]['Interval']}  ${parms['interval']}
   END

   IF  'maxrequests' in ${parms}
      Should Be Equal As Numbers   ${show[0]['MaxRequests']}  ${parms['maxrequests']}
   END

   IF  'maxreqsalgorithm' in ${parms}
      Should Be Equal As Numbers   ${show[0]['MaxReqsAlgorithm']}  1
   END
 
Fail Update Flow Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettingsmc updateflow ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Fail Update Maxreqs Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  ratelimitsettingsmc updatemaxreqs ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

Verify Flow Update
   [Arguments]  ${show}  &{parms}

   Should Be Equal  ${show[0]['ApiName']}  ${parms['apiname']}
   Should Be Equal  ${show[0]['FlowSettingsName']}  ${parms['flowsettingsname']}
   IF  '${parms['ratelimittarget']}' == 'AllRequests'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  1
   ELSE IF  '${parms['ratelimittarget']}' == 'PerIp'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  2
   ELSE IF  '${parms['ratelimittarget']}' == 'PerUser'
      Should Be Equal As Numbers   ${show[0]['RateLimitTarget']}  3
   END

   IF  'burstsize' in ${parms}
      Should Be Equal As Numbers   ${show[0]['BurstSize']}  ${parms['burstsize']}
   END

   IF  'reqspersecond' in ${parms}
      Should Be Equal As Numbers   ${show[0]['ReqsPerSecond']}  ${parms['reqspersecond']}
   END

   IF  'flowalgorithm' in ${parms}
      IF  '${parms['flowalgorithm']}' == 'TokenBucketAlgorithm'
         Should Be Equal As Numbers   ${show[0]['FlowAlgorithm']}  1
      ELSE
         Should Be Equal As Numbers   ${show[0]['FlowAlgorithm']}  2
      END
   END

Success Show Via mcctl
   [Arguments]  &{parms}

   IF  'noarg' not in &{parms}
      ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   ELSE
      ${parmss}=  Set Variable  ${Empty}
   END

   ${show}=  Run mcctl  ratelimitsettingsmc show ${parmss}  version=${version}

   Should Be True  'ApiName' in ${show[0]}
   Should Be True  'RateLimitTarget' in ${show[0]}
