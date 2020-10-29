*** Settings ***
Documentation  CreateAlertReceiver mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  2m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

*** Test Cases ***
CreateAlertReceiver - mcctl shall be able to create/delete email/slack alert
   [Documentation]
   ...  - send alertreceiver create via mcctl with various parms
   ...  - verify alertreceiver is created/deleted

   [Template]  Success Create/Delete Alert Receiver Via mcctl
      # email app 
      name=${recv_name} type=email severity=info app-org=${developer}
      name=${recv_name} type=email severity=info appname=x app-org=${developer}
      name=${recv_name} type=email severity=info appvers=x app-org=${developer}
      name=${recv_name} type=email severity=info app-cloudlet=x app-org=${developer}
      name=${recv_name} type=email severity=info app-cloudlet-org=x app-org=${developer}
      name=${recv_name} type=email severity=info app-org=${developer} appname=x appvers=x app-cloudlet=x app-cloudlet-org=x
      name=${recv_name} type=email severity=info app-org=${developer} appname=x appvers=x app-cloudlet=x app-cloudlet-org=x cluster=x cluster-org=x
      name=${recv_name} type=email email=x@yahoo.com severity=info app-org=${developer}

      # slack app
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info app-org=${developer}
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info appname=x app-org=${developer}
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info appvers=x app-org=${developer}
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info app-cloudlet=x app-org=${developer}
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info app-cloudlet-org=x app-org=${developer}
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info app-org=${developer} appname=x appvers=x app-cloudlet=x app-cloudlet-org=x
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info app-org=${developer} appname=x appvers=x app-cloudlet=x app-cloudlet-org=x cluster=x cluster-org=x

      # email cloudlet 
      name=${recv_name} type=email severity=info cloudlet-org=${developer}
      name=${recv_name} type=email severity=info cloudlet=x cloudlet-org=${developer}
      name=${recv_name} type=email email=x@yahoo.com severity=info cloudlet-org=${developer}

      # slack app
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info cloudlet-org=${developer}
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info cloudlet=x cloudlet-org=${developer}

      # email app and cloudlet
      name=${recv_name} type=email severity=info app-org=${developer} appname=x appvers=x app-cloudlet=x app-cloudlet-org=x cluster=x cluster-org=x cloudlet=x cloudlet-org=${developer}

      # slack app and cloudlet
      name=${recv_name} type=slack slack-channel=x slack-api-url=http://slack.com severity=info app-org=${developer} appname=x appvers=x app-cloudlet=x app-cloudlet-org=x cluster=x cluster-org=x cloudlet=x cloudlet-org=${developer}

CreateAlertReceiver - mcctl shall handle create failures
   [Documentation]
   ...  - send alertreceiver create via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Alert Receiver Via mcctl
      # invalid values
      name=${recv_name} type=emai severity=info app-org=${developer}                                         Error: Bad Request (400), Receiver type invalid
      name=${recv_name} type=email severity=inf app-org=${developer}                                         Error: Bad Request (400), Alert severity has to be one of "info", "warning", "error" 
      name=${recv_name} type=slack severity=info slack-channel=x slack-api-url=x app-org=${developer}        Error: Bad Request (400), Unable to create a receiver - Invalid Slack api URL 
      name=${recv_name} type=slack severity=info slack-channel=x slack-api-url=http:// app-org=${developer}  Error: Bad Request (400), Unable to create a receiver - bad response status 400 Bad Request[missing host for URL] 

      # missing values
      type=email severity=info app-org=${developer}                                    Error: missing required args: name 
      name=${recv_name} severity=info app-org=${developer}                             Error: missing required args: type 
      name=${recv_name} type=email app-org=${developer}                                Error: missing required args: severity
      name=${recv_name} type=email severity=info                                       Error: Bad Request (400), Either cloudlet, or app instance details have to be specified 
      name=${recv_name} type=slack app-org=${developer}                                Error: missing required args: severity
      name=${recv_name} type=slack severity=info slack-channel=x app-org=${developer}  Error: Bad Request (400), Slack URL, or channel are missing 
      name=${recv_name} type=slack severity=info slack-api-url=x app-org=${developer}  Error: Bad Request (400), Slack URL, or channel are missing 

*** Keywords ***
Setup
   ${recv_name}=  Get Default Alert Receiver Name
   Set Suite Variable  ${recv_name}

Success Create/Delete Alert Receiver Via mcctl
   [Arguments]  ${parms}

   Run mcctl  alertreceiver create ${parms} 
   Run mcctl  alertreceiver delete ${parms}

Fail Create Alert Receiver Via mcctl
   [Arguments]  ${parms}  ${error_msg}

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  alertreceiver create ${parms}
   Should Contain  ${std_create}  ${error_msg}
