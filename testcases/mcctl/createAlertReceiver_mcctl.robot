*** Settings ***
Documentation  CreateAlertReceiver mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

*** Test Cases ***
# ECQ-2905
CreateAlertReceiver - mcctl shall be able to create/delete email/slack alert
   [Documentation]
   ...  - send alertreceiver create via mcctl with various parms
   ...  - verify alertreceiver is created/deleted

   [Template]  Success Create/Delete Alert Receiver Via mcctl
      # email app 
      name=${recv_name}  type=email  severity=info  app-org=${developer}
      name=${recv_name}  type=email  severity=info  appname=x  app-org=${developer}
      name=${recv_name}  type=email  severity=info  appvers=x  app-org=${developer}
      name=${recv_name}  type=email  severity=info  app-cloudlet=x  app-org=${developer}
      name=${recv_name}  type=email  severity=info  app-cloudlet-org=x  app-org=${developer}
      name=${recv_name}  type=email  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x
      name=${recv_name}  type=email  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x  cluster=x  cluster-org=x
      name=${recv_name}  type=email  email=x@yahoo.com  severity=info  app-org=${developer}

      # email cluster 
      name=${recv_name}  type=email  severity=info  cluster-org=${developer}
      name=${recv_name}  type=email  severity=info  cluster=x  cluster-org=${developer}

      # slack app
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  appname=x  app-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  appvers=x  app-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-cloudlet=x  app-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-cloudlet-org=x  app-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x  cluster=x  cluster-org=x
 
      # slack cluster
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  cluster-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  cluster=x  cluster-org=${developer}

      # email cloudlet 
      name=${recv_name}  type=email  severity=info  cloudlet-org=${developer}
      name=${recv_name}  type=email  severity=info  cloudlet=x  cloudlet-org=${developer}
      name=${recv_name}  type=email  email=x@yahoo.com  severity=info  cloudlet-org=${developer}

      # slack cloudlet
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  cloudlet-org=${developer}
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  cloudlet=x  cloudlet-org=${developer}

      # region
      name=${recv_name}  type=email  severity=info  app-org=${developer}  region=US
      name=${recv_name}  type=email  severity=info  cluster-org=${developer}  region=US
      name=${recv_name}  type=email  severity=info  cloudlet-org=${developer}  region=US
      name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x  cluster=x  cluster-org=x  region=US
      name=${recv_name}  type=email  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x  cluster=x  cluster-org=x  region=US

# ECQ-2906
CreateAlertReceiver - mcctl shall handle create failures
   [Documentation]
   ...  - send alertreceiver create via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Alert Receiver Via mcctl
      # invalid values
      Error: Bad Request (400), Receiver type invalid                                                                    name=${recv_name}  type=emai  severity=info  app-org=${developer}
      Error: Bad Request (400), Alert severity has to be one of "info", "warning", "error"                               name=${recv_name}  type=email  severity=inf  app-org=${developer}
      Error: Bad Request (400), Unable to create a receiver - Invalid Slack api URL                                      name=${recv_name}  type=slack  severity=info  slack-channel=x  slack-api-url=x  app-org=${developer}
      Error: Bad Request (400), Unable to create a receiver - bad response status 400 Bad Request[missing host for URL]  name=${recv_name}  type=slack  severity=info  slack-channel=x  slack-api-url=http://  app-org=${developer}

      # missing values
      Error: missing required args: name                                                               type=email  severity=info  app-org=${developer}
      Error: missing required args: type                                                               name=${recv_name}  severity=info  app-org=${developer}
      Error: missing required args: severity                                                           name=${recv_name}  type=email  app-org=${developer}
      Error: Bad Request (400), Either cloudlet, cluster or app instance details have to be specified  name=${recv_name}  type=email  severity=info 
      Error: missing required args: severity                                                           name=${recv_name}  type=slack  app-org=${developer}
      Error: Bad Request (400), Both slack URL and slack channel must be specified                     name=${recv_name}  type=slack  severity=info  slack-channel=x  app-org=${developer}
      Error: Bad Request (400), Both slack URL and slack channel must be specified                     name=${recv_name}  type=slack  severity=info  slack-api-url=x  app-org=${developer}

      AppInst details cannot be specified if this receiver is for cloudlet alerts  name=${recv_name}  type=email  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x  cluster=x  cluster-org=x  cloudlet=x  cloudlet-org=${developer}
      AppInst details cannot be specified if this receiver is for cloudlet alerts  name=${recv_name}  type=slack  slack-channel=x  slack-api-url=http://slack.com  severity=info  app-org=${developer}  appname=x  appvers=x  app-cloudlet=x  app-cloudlet-org=x  cluster=x  cluster-org=x  cloudlet=x  cloudlet-org=${developer}

      # user
      Error: Bad Request (400), User is not specifiable, current logged in user will be used  name=${recv_name}  type=emai  severity=info  app-org=${developer}  user=x

*** Keywords ***
Setup
   ${recv_name}=  Get Default Alert Receiver Name
   Set Suite Variable  ${recv_name}

Success Create/Delete Alert Receiver Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   Run mcctl  alertreceiver create ${parmss} 
   ${show}=  Run mcctl  alertreceiver show ${parmss_modify} 

   Run mcctl  alertreceiver delete ${parmss}

   Should Be Equal  ${show[0]['Name']}  ${parms['name']}
   Should Be Equal  ${show[0]['Type']}  ${parms['type']}
   Should Be Equal  ${show[0]['Severity']}  ${parms['severity']}
   Should Be Equal  ${show[0]['User']}  mexadmin

   Run Keyword If  '${parms['type']}' == 'email' and 'email' in ${parms}  Should Be Equal  ${show[0]['Email']}  ${parms['email']}
   Run Keyword If  '${parms['type']}' == 'email' and 'email' not in ${parms}  Should Be Equal  ${show[0]['Email']}  mexadmin@mobiledgex.net

   Run Keyword If  '${parms['type']}' == 'slack' and 'slack-channel' in ${parms}  Should Be Equal  ${show[0]['SlackChannel']}  ${parms['slack-channel']}
   Run Keyword If  '${parms['type']}' == 'slack' and 'slack-api-url' in ${parms}  Should Be Equal  ${show[0]['SlackWebhook']}  <hidden>
 
   Run Keyword If  'appname' in ${parms}  Should Be Equal  ${show[0]['AppInst']['app_key']['name']}  ${parms['appname']}
   Run Keyword If  'app-org' in ${parms}  Should Be Equal  ${show[0]['AppInst']['app_key']['organization']}  ${parms['app-org']}
   Run Keyword If  'appvers' in ${parms}  Should Be Equal  ${show[0]['AppInst']['app_key']['version']}  ${parms['appvers']}
   Run Keyword If  'app-cloudlet' in ${parms}  Should Be Equal  ${show[0]['AppInst']['cluster_inst_key']['cloudlet_key']['name']}  ${parms['app-cloudlet']}
   Run Keyword If  'app-cloudlet-org' in ${parms}  Should Be Equal  ${show[0]['AppInst']['cluster_inst_key']['cloudlet_key']['organization']}  ${parms['app-cloudlet-org']}

   Run Keyword If  'cluster' in ${parms}  Should Be Equal  ${show[0]['AppInst']['cluster_inst_key']['cluster_key']['name']}  ${parms['cluster']}
   Run Keyword If  'cluster-org' in ${parms}  Should Be Equal  ${show[0]['AppInst']['cluster_inst_key']['organization']}  ${parms['cluster-org']}

   Run Keyword If  'cloudlet' in ${parms}  Should Be Equal  ${show[0]['Cloudlet']['name']}  ${parms['cloudlet']}
   Run Keyword If  'cloudlet-org' in ${parms}  Should Be Equal  ${show[0]['Cloudlet']['organization']}  ${parms['cloudlet-org']}

   Run Keyword If  'region' in ${parms}  Should Be Equal  ${show[0]['Region']}  ${parms['region']}

Fail Create Alert Receiver Via mcctl
   [Arguments]  ${error_msg}  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  alertreceiver create ${parmss}
   Should Contain  ${std_create}  ${error_msg}
