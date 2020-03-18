*** Settings ***
Documentation  DeletePrivacyPolicy fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_fake}=  tmus
${cloudlet_name_fake}=  tmocloud-1

*** Test Cases ***
DeletePrivacyPolicy - delete without region shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no region specified"}')  Delete Privacy Policy  token=${token}  use_defaults=${False}

DeletePrivacyPolicy - delete without token shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy without token
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Delete Privacy Policy  region=${region}  use_defaults=${False}

DeletePrivacyPolicy - delete without parms shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy with no parms 
   ...  verify error is returned 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {} not found"}')  Delete Privacy Policy  region=${region}  token=${token}  use_defaults=${False}

DeletePrivacyPolicy - delete without policy name shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy with no policy name 
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"mobiledgex\\\\"} not found"}')  Delete Privacy Policy  developer_org_name=mobiledgex  region=${region}  token=${token}  use_defaults=${False}

DeletePrivacyPolicy - delete with unknown org name shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy with unknown org name
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Delete Privacy Policy  developer_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}

DeletePrivacyPolicy - delete without developer name shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy with no developer name
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"name\\\\":\\\\"x\\\\"} not found"}')  Delete Privacy Policy  policy_name=x  region=${region}  token=${token}  use_defaults=${False}

DeletePrivacyPolicy - delete with policy not found shall return error
   [Documentation]
   ...  send DeletePrivacyPolicy with a policy that does not exist 
   ...  verify error is returned

   ${name}=  Get Default Privacy Policy Name
   ${dev}=   Get Default Developer Name


   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"${dev}\\\\",\\\\"name\\\\":\\\\"${name}\\\\"} not found"}')  Delete Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

DeletePrivacyPolicy - delete policy in use by cluster instance shall retun error
   [Documentation]
   ...  send DeletePrivacyPolicy with policy in use by a cluster instance 
   ...  verify proper error is returned 
   
   Create Flavor  region=${region}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy in use by ClusterInst"}')  Delete Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

