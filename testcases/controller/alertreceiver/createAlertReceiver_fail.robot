*** Settings ***
Documentation  CreateAlertReceiver failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${operator_name_fake}=  tmus
${cloudlet_name_fake}=  tmocloud-1
${operator_name_azure}=  azure
${cloudlet_name_azure}=  automationAzureCentralCloudlet
${operator_name_gcp}=   gcp
${cloudlet_name_gcp}=  automationGcpCentralCloudlet


*** Test Cases ***
CreateAlertReceiver - create without parms shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Receiver name has to be specified"}')  Create Alert Receiver  token=${token}  use_defaults=${False}

CreateAlertReceiver - create without receiver name shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   #EDGECLOUD-3678 create alertreceiver without receiver name gives bad error message

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Receiver name has to be specified"}')  Create Alert Receiver  type=email  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}
   #${error}=  Run Keyword and Expect Error  *   Create Alert Receiver  type=email  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

   #Should Contain  ${error}  ady

CreateAlertReceiver - create with invalid type shall return error
   [Documentation]
   ...  send CreateAlertReceiver with invalid type
   ...  verify error is returned

   # no type
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Receiver type invalid"}')  Create Alert Receiver  receiver_name=email  severity=error  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

   # invalid type value
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Receiver type invalid"}')  Create Alert Receiver  receiver_name=email  severity=error  type=x  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

   # empty type
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Receiver type invalid"}')  Create Alert Receiver  receiver_name=email  severity=error  type=${EMPTY}  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

CreateAlertReceiver - create without app/cloudlet shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Either cloudlet, or app instance details have to be specified"}')  Create Alert Receiver  receiver_name=xxx  type=email  token=${token}  use_defaults=${False}

CreateAlertReceiver - duplicate create shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Create Alert Receiver  developer_org_name=tmus  
   
   ${error}=  Run Keyword and Expect Error  *  Create Alert Receiver  developer_org_name=tmus
   Should Contain  ${error}  code=400
   Should Contain  ${error}  Unable to create a receiver - bad response status 409 Conflict[Receiver Exists - delete it first]

CreateAlertReceiver - create without all app parms shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

#   Run Keyword and Expect Error  ('code=400', 'error={"message":"Either cloudlet, or app instance details have to be specified"}')  Create Alert Receiver  receiver_name=xxx  type=email  app_name=x  token=${token}  use_defaults=${False}
#   Run Keyword and Expect Error  ('code=400', 'error={"message":"Either cloudlet, or app instance details have to be specified"}')  Create Alert Receiver  receiver_name=xxx  type=email  app_name=x  app_version=1.0  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Either cloudlet, or app instance details have to be specified"}')  Create Alert Receiver  receiver_name=xxx  type=email  app_version=1.0  developer_org_name=x  app_name=x   token=${token}  use_defaults=${False}
#   Run Keyword and Expect Error  ('code=400', 'error={"message":"Either cloudlet, or app instance details have to be specified"}')  Create Alert Receiver  receiver_name=xxx  type=email  app_version=1.0   token=${token}  use_defaults=${False}

CreateAlertReceiver - create without severity shall return error
   [Documentation]
   ...  send CreateAlertReceive without severity
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Alert severity has to be one of \\\\"error\\\\", \\\\"warning\\\\", \\\\"info\\\\""}')  Create Alert Receiver  receiver_name=xxx  type=email  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

CreateAlertReceiver - create with invalid severity shall return error
   [Documentation]
   ...  send CreateAlertReceive with invalid severity
   ...  verify error is returned

   # no severity
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Alert severity has to be one of \\\\"error\\\\", \\\\"warning\\\\", \\\\"info\\\\""}')  Create Alert Receiver  receiver_name=xxx  type=email  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

   # severity with invalid value
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Alert severity has to be one of \\\\"error\\\\", \\\\"warning\\\\", \\\\"info\\\\""}')  Create Alert Receiver  receiver_name=xxx  type=email  severity=x  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

   # severity with empty value
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Alert severity has to be one of \\\\"error\\\\", \\\\"warning\\\\", \\\\"info\\\\""}')  Create Alert Receiver  receiver_name=xxx  type=email  severity=${EMPTY}  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

