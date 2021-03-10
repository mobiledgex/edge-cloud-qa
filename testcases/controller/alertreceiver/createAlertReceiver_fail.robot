*** Settings ***
Documentation  CreateAlertReceiver failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${developer}=  MobiledgeX

*** Test Cases ***
# ECQ-2909
CreateAlertReceiver - missing/invalid/empty parms shall return error
   [Documentation]
   ...  - send alertreceiver create with various missing/invalid/empty parms
   ...  - verify proper error is received
 
   [Template]  Fail Create Alert Receiver

   # no/invalid token
   ('code\=400', 'error\={"message":"no bearer token found"}')   use_defaults=${False}  
   ('code\=401', 'error\={"message":"invalid or expired jwt"}')  token=xx  use_defaults=${False}

   # no parms
   ('code\=400', 'error\={"message":"Receiver name has to be specified"}')  token=${super_token}  use_defaults=${False}

   # no receiver name
   ('code\=400', 'error\={"message":"Receiver name has to be specified"}')  type=email  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name has to be specified"}')  type=email  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name has to be specified"}')  severity=info  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name has to be specified"}')  region=info  token=${super_token}  use_defaults=${False}

   # invalid receiver name
   ('code\=400', 'error\={"message":"Receiver name is invalid"}')  receiver_name=%name  type=email  severity=info  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name is invalid"}')  receiver_name=n#ame  type=email  severity=info  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name is invalid"}')  receiver_name=@name  type=email  severity=info  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name is invalid"}')  receiver_name=n:ame  type=email  severity=info  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver name is invalid"}')  receiver_name=!@@#$%%#@$  type=email  email_address=x@x.com  severity=info     operator_org_name=${developer}   developer_org_name=${developer}  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US

   # no/invalid/empty type
   ('code\=400', 'error\={"message":"Receiver type invalid"}')  receiver_name=email  severity=error  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver type invalid"}')  receiver_name=email  severity=error  type=x  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver type invalid"}')  receiver_name=email  severity=error  type=${EMPTY}  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}

   # no app/cloudlet/cluster
   ('code\=400', 'error\={"message":"Either cloudlet, cluster or app instance details have to be specified"}')  receiver_name=xxx  type=email  severity=info  token=${super_token}  use_defaults=${False}

   # no/invalid/empty severity
   ('code\=400', 'error\={"message":"Alert severity has to be one of \\\\"info\\\\", \\\\"warning\\\\", \\\\"error\\\\""}')  receiver_name=xxx  type=email  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Alert severity has to be one of \\\\"info\\\\", \\\\"warning\\\\", \\\\"error\\\\""}')  receiver_name=xxx  type=email  severity=x  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Alert severity has to be one of \\\\"info\\\\", \\\\"warning\\\\", \\\\"error\\\\""}')  receiver_name=xxx  type=email  severity=${EMPTY}  app_name=x  app_version=x  developer_org_name=x  token=${super_token}  use_defaults=${False}

   # no/invalid slack channel/url
   ('code\=400', 'error\={"message":"Both slack URL and slack channel must be specified"}')  receiver_name=xxx  severity=info  type=slack  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Both slack URL and slack channel must be specified"}')  receiver_name=xxx  severity=info  type=slack  slack_channel=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Both slack URL and slack channel must be specified"}')  receiver_name=xxx  severity=info  type=slack  slack_api_url=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Both slack URL and slack channel must be specified"}')  receiver_name=xxx  severity=info  type=slack  slack_channel=${Empty}  slack_api_url=http://x.com  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Both slack URL and slack channel must be specified"}')  receiver_name=xxx  severity=info  type=slack  slack_channel=xx  slack_api_url=${Empty}  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Both slack URL and slack channel must be specified"}')  receiver_name=xxx  severity=info  type=slack  slack_channel=${Empty}  slack_api_url=${Empty}  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to create a receiver - Invalid Slack api URL"}')  receiver_name=xxx  severity=info  type=slack  slack_channel=x  slack_api_url=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Unable to create a receiver - bad response status 400 Bad Request[missing host for URL]"}')  receiver_name=xxx  severity=info  type=slack  slack_channel=x  slack_api_url=http://  developer_org_name=x  token=${super_token}  use_defaults=${False}

   # invalid email
   ('code\=400', 'error\={"message":"Receiver email is invalid"}')  receiver_name=email  severity=info  type=email  email_address=x  developer_org_name=x  token=${super_token}  use_defaults=${False}
   ('code\=400', 'error\={"message":"Receiver email is invalid"}')  receiver_name=email  severity=info  type=email  email_address=x.com  developer_org_name=x  token=${super_token}  use_defaults=${False}

   # app and cloudlet
   ('code\=400', 'error\={"message":"AppInst details cannot be specified if this receiver is for cloudlet alerts"}')  type=email  severity=info  developer_org_name=developer  operator_org_name=developer  token=${super_token}
   ('code\=400', 'error\={"message":"AppInst details cannot be specified if this receiver is for cloudlet alerts"}')  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info  developer_org_name=developer  operator_org_name=developer  token=${super_token}
   ('code\=400', 'error\={"message":"AppInst details cannot be specified if this receiver is for cloudlet alerts"}')  type=slack  slack_channel=${slack_channel}  slack_api_url=${slack_api_url}  severity=info     operator_org_name=developer   developer_org_name=developer  app_name=x  app_version=1  app_cloudlet_name=appcloudlet  app_cloudlet_org=apporg  cluster_instance_name=y  cluster_instance_developer_org_name=corg  region=US  token=${super_token}

   # cluster and cloudlet
   ('code\=400', 'error\={"message":"AppInst details cannot be specified if this receiver is for cloudlet alerts"}')   type=email  severity=warning  operator_org_name=operator  cloudlet_name=x  cluster_instance_name=mycluster  cluster_instance_developer_org_name=developer  token=${super_token}
   ('code\=400', 'error\={"message":"AppInst details cannot be specified if this receiver is for cloudlet alerts"}')  type=email  severity=info  cluster_instance_developer_org_name=developer  operator_org_name=developer  token=${super_token}
   ('code\=400', 'error\={"message":"AppInst details cannot be specified if this receiver is for cloudlet alerts"}')  type=slack  slack_channel=slack_channel  slack_api_url=http://x.com  severity=info  cluster_instance_developer_org_name=developer  operator_org_name=developer  region=US  token=${super_token}

# ECQ-2910
CreateAlertReceiver - duplicate create shall return error
   [Documentation]
   ...  - send alertreceiver twice for same receiver name
   ...  - verify error is returned

   Create Alert Receiver  developer_org_name=dmuus  token=${super_token}
   
   ${error}=  Run Keyword and Expect Error  *  Create Alert Receiver  developer_org_name=dmuus  token=${super_token}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  Unable to create a receiver - bad response status 409 Conflict[Receiver Exists - delete it first]

# ECQ-2911
CreateAlertReceiver - create with app from another user shall return error
   [Documentation]
   ...  - create user1 and user2
   ...  - create org as user1
   ...  - create alertreceiver as user1 and verify succeeds
   ...  - send alertreceiver as user2 with org from user1
   ...  - verify error is returned

   ${receiver_name}=  Get Default Alert Receiver Name

   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   # Verify Email  email_address=${emailepoch}
   Unlock User
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   # Verify Email  email_address=${emailepoch2}
   Unlock User
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   ${alert}=  Create Alert Receiver  token=${user_token}  receiver_name=${receiver_name}1  type=email  severity=info  developer_org_name=${orgname}  #use_defaults=${False}

   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')  Create Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}2  type=email  severity=info  developer_org_name=${orgname}  #use_defaults=${False}

   ${adduser}=   Adduser Role   orgname=${orgname}   username=${epochusername2}   role=DeveloperManager    token=${user_token}     use_defaults=${False}

   ${alert}=  Create Alert Receiver  token=${user_token2}  receiver_name=${receiver_name}2  type=email  severity=info  developer_org_name=${orgname}  #use_defaults=${False}

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${super_token}=  Get Super Token
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Set Variable  ${epochusername}2
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}2  @gmail.com

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${epochusername}
   Set Suite Variable  ${epochusername2}
   Set Suite Variable  ${emailepoch}
   Set Suite Variable  ${emailepoch2}

Fail Create Alert Receiver
   [Arguments]  ${error_msg}  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Create Alert Receiver  &{parms}
   Should Be Equal  ${std_create}  ${error_msg}

