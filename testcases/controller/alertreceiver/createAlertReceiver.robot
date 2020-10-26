*** Settings ***
Documentation  CreateAlertReceiver

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning
 
Test Timeout  1m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${counter}=  ${0}

*** Test Cases ***
CreateAlertReceiver - shall be able to create email alert
   [Documentation]
   ...  - send alertreceiver create with type=email and suppored severities and app/cloudlets
   ...  - verify alertreceiver is created

   EDGECLOUD-3854 unable to delete alertreceivers with special chars

   [Template]  Create an Alert Receiver
      # cloudlet
      type=email  severity=info     operator_org_name=${developer}
      name=my alert  type=email  email_address=x@x.com  severity=info     operator_org_name=${developer}  cloudlet_name=x
      type=email  severity=warning     operator_org_name=${developer}
      type=email  severity=warning     operator_org_name=${developer}  cloudlet_name=x
      type=email  email_address=x@x.com  severity=error     operator_org_name=${developer}
      name=dfafasfasfasfafafafafafasffafafafasfafafafa af asf asdf asdf asdf asdf asdfasdfas dfasdfasdf  type=email  severity=error     operator_org_name=${developer}  cloudlet_name=x

      # app
      type=email  severity=info     developer_org_name=${developer}  
      type=email  severity=warning     developer_org_name=${developer}  app_name=x
      name=12345  type=email  severity=error     developer_org_name=${developer}  app_name=x  app_version=1
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

      # app and cloudlet
      type=email  severity=info  developer_org_name=${developer}  operator_org_name=${developer}
      name=!@@#$%%#@$  type=email  email_address=x@x.com  severity=info     operator_org_name=${developer}   developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg

      # add show checks for each once show filter is there

CreateAlertReceiver - shall be able to create slack alert
   [Documentation]
   ...  - send alertreceiver create with type=slack and suppored severities and app/cloudlets
   ...  - verify alertreceiver is created

   [Template]  Create an Alert Receiver
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}  cloudlet_name=x
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=warning     operator_org_name=${developer}  cloudlet_name=x
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=error     operator_org_name=${developer}  cloudlet_name=x

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

   # app and cloudlet
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info  developer_org_name=${developer}  operator_org_name=${developer}
      type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=${developer}   developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${receiver_name}=  Get Default Alert Receiver Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${receiver_name}
   Set Suite Variable  ${developer_name}

Create An Alert Receiver
   [Arguments]  ${name}=${None}  ${type}=slack  ${severity}=${None}  ${developer_org_name}=${None}  ${app_name}=${None}  ${app_version}=${None}  ${app_cloudlet_name}=${None}  ${app_cloudlet_org}=${None}  ${cluster_instance_name}=${None}  ${cluster_instance_developer_org_name}=${None}  ${cloudlet_name}=${None}  ${operator_org_name}=${None}  ${slack_channel}=${None}  ${slack_api_url}=${None}  ${email_address}=${None}
 
   ${name}=  Set Variable If  '${Name}' == '${None}'  ${receiver_name}${counter}  ${Name}

   ${alert}=  Create Alert Receiver  receiver_name=${name}  type=${type}  severity=${severity}     developer_org_name=${developer_org_name}  app_name=${app_name}  app_version=${app_version}  app_cloudlet_name=${appcloudlet_name}  app_cloudlet_org=${app_cloudlet_org}  cluster_instance_name=${cluster_instance_name}   cluster_instance_developer_org_name=${cluster_instance_developer_org_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_org_name}  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  email_address=${email_address}

   #${alert}=  Create Alert Receiver  receiver_name=${receiver_name}${counter}  &{alert_args}

   #Should Be Equal  ${alert['Name']}      ${receiver_name}${counter}
   #Should Be Equal  ${alert['Type']}      ${type}
   #Should Be Equal  ${alert['Severity']}  ${severity}
   #Should Be Equal  ${alert['User']}      mexadmin 
   #Should Be Equal  ${alert['Email']}     mexadmin@mobiledgex.net 


   #Run Keyword If  '${developer_org_name}' != ${None}   Should Be Equal  ${alert['AppInst']['appkey']['name']}  ${app_name}

   ${counter}=  Evaluate  ${counter} + 1
   Set Test Variable  ${counter}
