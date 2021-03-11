*** Settings ***
Documentation  CreateAlertReceiver

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections 
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning
 
Test Timeout  1m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${operator}=  TDG

${counter}=  ${0}

*** Test Cases ***
# ECQ-2907
CreateAlertReceiver - shall be able to create email alert
   [Documentation]
   ...  - send alertreceiver create with type=email and suppored severities and app/cluster/cloudlets
   ...  - verify alertreceiver is created

   [Template]  Create an Alert Receiver
      # cluster
      type=email  severity=info     cluster_instance_developer_org_name=${developer}
      type=email  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}
      type=email  email_address=x@x.com  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}
      type=email  email_address=x@x.com  severity=warning  cluster_instance_developer_org_name=${developer}  region=US
      type=email  email_address=x-1@x.com  severity=warning  cluster_instance_developer_org_name=${developer}  region=US
      type=email  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}  region=US

      # cloudlet
      type=email  severity=info     operator_org_name=${operator}
      type=email  severity=warning     operator_org_name=${operator}
      type=email  severity=warning     operator_org_name=${operator}  cloudlet_name=x
      type=email  email_address=x@x.com  severity=error     operator_org_name=${operator}
      type=email  email_address=my-email@x.com  severity=error     operator_org_name=${operator}
      type=email  severity=info     operator_org_name=${operator}  region=US
      type=email  severity=warning     operator_org_name=${operator}  cloudlet_name=x  region=US

      # app
      type=email  severity=info     developer_org_name=${developer}  
      type=email  severity=warning     developer_org_name=${developer}  app_name=x
      type=email  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  
      type=email  email_address=x@x.com  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y
      type=email  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=email  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=email  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=email  severity=error     developer_org_name=${developer}  app_version=1
      type=email  severity=info     developer_org_name=${developer}  cluster_instance_name=y
      type=email  email_address=x@x.com  severity=warning     developer_org_name=${developer}  cluster_instance_developer_org_name=corg
      type=email  severity=info     developer_org_name=${developer}  app_cloudlet_name=appcloudlet
      type=email  severity=error     developer_org_name=${developer}  app_cloudlet_org=appcloudlet
      type=email  severity=info     developer_org_name=${developer}  region=US
      type=email  severity=warning     developer_org_name=${developer}  app_name=x  region=US
      type=email  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  region=US
      type=email  email_address=x@x.com  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  region=US
      type=email  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=email  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=email  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=email  email_address=my-email@x.com  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  region=US

      # receiver name
      receiver_name=x          type=email  severity=info     developer_org_name=${developer}
      receiver_name=1          type=email  severity=info     developer_org_name=${developer}
      receiver_name=0x         type=email  severity=info     developer_org_name=${developer}
      receiver_name=x_x        type=email  severity=info     developer_org_name=${developer}
      receiver_name=x.xx       type=email  severity=info     developer_org_name=${developer}
      receiver_name=x,xx       type=email  severity=info     developer_org_name=${developer}
      receiver_name=x!xx       type=email  severity=info     developer_org_name=${developer}
      receiver_name=x .&_!,xx  type=email  severity=info     developer_org_name=${developer}
      receiver_name=dfafasfasfasfafafafafafasffafafafasfafafafa af asf asdf asdf asdf asdf asdfasdfas dfasdfasdf  type=email  severity=error     operator_org_name=${developer}  cloudlet_name=x
      receiver_name=12345  type=email  severity=error     developer_org_name=${developer}  app_name=x  app_version=1
      receiver_name=my alert  type=email  email_address=x@x.com  severity=info     operator_org_name=${developer}  cloudlet_name=x
      receiver_name=my alert2  type=email  email_address=x-email@x.com  severity=info     operator_org_name=${developer}  cloudlet_name=x

# ECQ-2908
CreateAlertReceiver - shall be able to create slack alert
   [Documentation]
   ...  - send alertreceiver create with type=slack and suppored severities and app/cluster/cloudlets
   ...  - verify alertreceiver is created

   [Template]  Create an Alert Receiver
      # cluster
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     cluster_instance_developer_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning  cluster_instance_developer_org_name=${developer}  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}  region=US
      type=slack  slack_channel=xxxx              slack_api_url=${slack_api_url}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}  region=US

      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}  cloudlet_name=x
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     operator_org_name=${developer}  cloudlet_name=x
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     operator_org_name=${developer}  cloudlet_name=x
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}  cloudlet_name=x  region=US
      type=slack  slack_channel=slack_channel  slack_api_url=${slack_api_url}     severity=info     operator_org_name=${developer}  cloudlet_name=x  region=US

      # app
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  app_name=x
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     developer_org_name=${developer}  app_name=x  app_version=1
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     developer_org_name=${developer}  app_version=1
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  cluster_instance_name=y
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  cluster_instance_developer_org_name=corg
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_cloudlet_name=appcloudlet
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     developer_org_name=${developer}  app_cloudlet_org=appcloudlet
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  app_name=x  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     developer_org_name=${developer}  app_name=x  app_version=1  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=slack  slack_channel=slack_channel  slack_api_url=${slack_api_url}     severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US

      # receiver name
      receiver_name=x          type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=1          type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=0x         type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=x_x        type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=x.xx       type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=x,xx       type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=x!xx       type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=x .&_!,xx  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}
      receiver_name=x .&_!,xq  type=slack  slack_channel=slack_channel     slack_api_url=${slack_api_url}  severity=info     developer_org_name=${developer}

# ECQ-3260
CreateAlertReceiver - shall be able to create pagerduty alert
   [Documentation]
   ...  - send alertreceiver create with type=pagerduty and suppored severities and app/cluster/cloudlets
   ...  - verify alertreceiver is created

   [Template]  Create an Alert Receiver
      # cluster
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     cluster_instance_developer_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning  cluster_instance_developer_org_name=${developer}  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}  region=US
      type=pagerduty  pagerduty_integration_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx             severity=warning  cluster_instance_name=mycluster  cluster_instance_developer_org_name=${developer}  region=US

      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     operator_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     operator_org_name=${developer}  cloudlet_name=x
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     operator_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     operator_org_name=${developer}  cloudlet_name=x
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=error     operator_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=error     operator_org_name=${developer}  cloudlet_name=x
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     operator_org_name=${developer}  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     operator_org_name=${developer}  cloudlet_name=x  region=US
      type=pagerduty  pagerduty_integration_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj     severity=info     operator_org_name=${developer}  cloudlet_name=x  region=US

      # app
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  app_name=x
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=error     developer_org_name=${developer}  app_name=x  app_version=1
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=error     developer_org_name=${developer}  app_version=1
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  cluster_instance_name=y
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  cluster_instance_developer_org_name=corg
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_cloudlet_name=appcloudlet
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=error     developer_org_name=${developer}  app_cloudlet_org=appcloudlet
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  app_name=x  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=error     developer_org_name=${developer}  app_name=x  app_version=1  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US
      type=pagerduty  pagerduty_integration_key=slack_channelxxxxxxxxxxxxxxxxxxj     severity=warning     developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US

      # receiver name
      receiver_name=x          type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=1          type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=0x         type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=x_x        type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=x.xx       type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=x,xx       type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=x!xx       type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=x .&_!,xx  type=pagerduty  pagerduty_integration_key=${pagerduty_key}  severity=info     developer_org_name=${developer}
      receiver_name=x .&_!,xq  type=pagerduty  pagerduty_integration_key=slack_channelxxxxxxxxxxxxxxxxxxx     severity=info     developer_org_name=${developer}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${receiver_name_default}=  Get Default Alert Receiver Name

   Set Suite Variable  ${receiver_name_default}

Create An Alert Receiver
   [Arguments]  &{parms}
   #[Arguments]  ${name}=${None}  ${type}=slack  ${severity}=${None}  ${developer_org_name}=${None}  ${app_name}=${None}  ${app_version}=${None}  ${app_cloudlet_name}=${None}  ${app_cloudlet_org}=${None}  ${cluster_instance_name}=${None}  ${cluster_instance_developer_org_name}=${None}  ${cloudlet_name}=${None}  ${operator_org_name}=${None}  ${slack_channel}=${None}  ${slack_api_url}=${None}  ${email_address}=${None}

   &{parms}=  Run Keyword If  'receiver_name' not in ${parms}  Set To Dictionary  ${parms}  receiver_name=${receiver_name_default}${counter}  ELSE  Set Variable  ${parms}
   ${counter}=  Evaluate  ${counter} + 1
   Set Test Variable  ${counter}
 
   #${name}=  Set Variable If  '${Name}' == '${None}'  ${receiver_name}${counter}  ${Name}

   ${alert}=  Create Alert Receiver  &{parms}  token=${token}  use_defaults=${False}

   #${alert}=  Create Alert Receiver  receiver_name=${name}  type=${type}  severity=${severity}     developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  app_cloudlet_name=${appcloudlet_name}  app_cloudlet_org=${app_cloudlet_org}  cluster_instance_name=${cluster_instance_name}   cluster_instance_developer_org_name=${cluster_instance_developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_org_name}  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  email_address=${email_address}

   #${alert}=  Create Alert Receiver  receiver_name=${receiver_name}${counter}  &{alert_args}

   Should Be Equal  ${alert['Name']}      ${parms['receiver_name']}
   Should Be Equal  ${alert['Type']}      ${parms['type']}
   Should Be Equal  ${alert['Severity']}  ${parms['severity']}
   Should Be Equal  ${alert['User']}      mexadmin 
   #Run Keyword If  'email_address' in ${parms}  Should Be Equal  ${alert['Email']}  ${parms['email_address']}  ELSE  Should Be Equal  ${alert['Email']}  mexadmin@mobiledgex.net 
   Run Keyword If  'email_address' in ${parms}  Verify Email Alert  ${alert}  &{parms}
   Run Keyword If  'slack_channel' in ${parms} or 'slack_api_url' in ${parms}  Verify Slack Alert  ${alert}  &{parms}
   Run Keyword If  'pagerduty_integration_key' in ${parms}  Verify PagerDuty Alert  ${alert}  &{parms}
   Run Keyword If  'operator_org_name' in ${parms}  Should Be Equal  ${alert['Cloudlet']['organization']}  ${parms['operator_org_name']}  
   Run Keyword If  'cloudlet_name' in ${parms}  Should Be Equal  ${alert['Cloudlet']['name']}  ${parms['cloudlet_name']}  
   Run Keyword If  'developer_org_name' in ${parms}  Should Be Equal  ${alert['AppInst']['app_key']['organization']}  ${parms['developer_org_name']}  
   Run Keyword If  'app_name' in ${parms}  Should Be Equal  ${alert['AppInst']['app_key']['name']}  ${parms['app_name']}  
   Run Keyword If  'app_version' in ${parms}  Should Be Equal  ${alert['AppInst']['app_key']['version']}  ${parms['app_version']}  
   Run Keyword If  'app_cloudlet_name' in ${parms}  Should Be Equal  ${alert['AppInst']['cluster_inst_key']['cloudlet_key']['name']}  ${parms['app_cloudlet_name']}  
   Run Keyword If  'cluster_instance_name' in ${parms}  Should Be Equal  ${alert['AppInst']['cluster_inst_key']['cluster_key']['name']}  ${parms['cluster_instance_name']}  
   Run Keyword If  'cluster_instance_developer_org_name' in ${parms}  Should Be Equal  ${alert['AppInst']['cluster_inst_key']['organization']}  ${parms['cluster_instance_developer_org_name']}  
   Run Keyword If  'region' in ${parms}  Should Be Equal  ${alert['Region']}  ${parms['region']}

Verify Email Alert
   [Arguments]  ${alert}  &{parms}

   Run Keyword If  'email_address' in ${parms}  Should Be Equal  ${alert['Email']}  ${parms['email_address']}  ELSE  Should Be Equal  ${alert['Email']}  mexadmin@mobiledgex.net

Verify PagerDuty Alert
   [Arguments]  ${alert}  &{parms}

   Run Keyword If  'pagerduty_integration_key' in ${parms}  Should Be Equal  ${alert['PagerDutyIntegrationKey']}  <hidden>
   Run Keyword If  'pagerduty_integration_key' in ${parms}  Should Be Equal  ${alert['PagerDutyApiVersion']}  v2

Verify Slack Alert
   [Arguments]  ${alert}  &{parms}

   ${channel}=  Run Keyword If  '#' in "${parms['slack_channel']}"  Set Variable  ${parms['slack_channel']}
   ...  ELSE  Set Variable  \#${parms['slack_channel']}
 
   #Run Keyword If  'slack_channel' in ${parms}  Should Be Equal  ${alert['SlackChannel']}  ${parms['slack_channel']}
   #Run Keyword If  'slack_api_url' in ${parms}  Should Be Equal  ${alert['SlackWebhook']}  <hidden>
   Should Be Equal  ${alert['SlackChannel']}  ${channel}
   Should Be Equal  ${alert['SlackWebhook']}  <hidden>

