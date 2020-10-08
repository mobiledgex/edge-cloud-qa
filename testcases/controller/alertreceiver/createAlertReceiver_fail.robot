*** Settings ***
Documentation  CreateAlertReceiver failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${operator_name_fake}=  dmuus
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

CreateAlertReceiver - create without type shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Receiver type invalid"}')  Create Alert Receiver  receiver_name=email  app_name=x  app_version=x  developer_org_name=x  token=${token}  use_defaults=${False}

CreateAlertReceiver - create without app/cloudlet shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Either cloudlet, or app instance details have to be specified"}')  Create Alert Receiver  receiver_name=xxx  type=email  token=${token}  use_defaults=${False}

CreateAlertReceiver - duplicate create shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Create Alert Receiver  developer_org_name=dmuus  
   
   ${error}=  Run Keyword and Expect Error  *  Create Alert Receiver  developer_org_name=dmuus
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


*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

