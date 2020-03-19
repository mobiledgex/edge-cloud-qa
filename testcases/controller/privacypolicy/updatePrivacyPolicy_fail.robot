*** Settings ***
Documentation  UpdatePrivacyPolicy fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_fake}=  tmus
${cloudlet_name_fake}=  tmocloud-1
${operator_name_azure}=  azure
${cloudlet_name_azure}=  automationAzureCentralCloudlet 
${operator_name_gcp}=   gcp 
${cloudlet_name_gcp}=  automationGcpCentralCloudlet


*** Test Cases ***
UpdatePrivacyPolicy - update without region shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no region specified"}')  Update Privacy Policy  token=${token}  use_defaults=${False}

UpdatePrivacyPolicy - update without token shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy without token
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Update Privacy Policy  region=${region}  use_defaults=${False}

UpdatePrivacyPolicy - update without parms shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with no parms 
   ...  verify error is returned 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {} not found"}')  Update Privacy Policy  region=${region}  token=${token}  use_defaults=${False}

UpdatePrivacyPolicy - update without policy name shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with no policy name 
   ...  verify error is returned
   EDGECLOUD-1953 - PrivacyPolicy - update without a policy name returns wrong error
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"developer\\\\":\\\\"mobiledgex\\\\"} not found"}')  Update Privacy Policy  developer_org_name=mobiledgex  region=${region}  token=${token}  use_defaults=${False}

UpdatePrivacyPolicy - update with unknown org name shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with unknown org name
   ...  verify error is returned

   #Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Update Privacy Policy  developer_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"xxxx\\\\"} not found"}')  Update Privacy Policy  developer_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}

UpdatePrivacyPolicy - update without developer name shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with no developer name
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"name\\\\":\\\\"x\\\\"} not found"}')  Update Privacy Policy  policy_name=x  region=${region}  token=${token}  use_defaults=${False}

UpdatePrivacyPolicy - update without protocol shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy without protocol
   ...  verify error is returned
   EDGECLOUD-1933 PrivacyPolicy - update policy does not give error when updating without protocol and only 1 rule
   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   #&{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   #&{rule2}=  Create Dictionary  protocol=icmp  remote_cidr=1.2.1.1/1
   @{rulelist}=  Create List  ${rule1}  #${rule2}
   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  remote_cidr=2.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Update Privacy Policy  region=${region}  rule_list=${rulelist} 

UpdatePrivacyPolicy - update with invalid CIDR shall return error 
   [Documentation]
   ...  send UpdatePrivacyPolicy with invalid CIDR 
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=x 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invalid CIDR address: x"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invalid CIDR address: 1.1.1.1"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=256.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invalid CIDR address: 256.1.1.1/1"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1/33
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invalid CIDR address: 1.1.1.1/33"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   EDGECLOUD-1933 PrivacyPolicy - update policy does not give error when updating without protocol and only 1 rule
   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"invalid CIDR address: "}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

UpdatePrivacyPolicy - update with invalid minport shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with invalid min port 
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid POST data"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid POST data"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 65536"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

UpdatePrivacyPolicy - update with invalid maxport shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with invalid max port
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid POST data"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid POST data"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid max port range: 65536"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

UpdatePrivacyPolicy - update with icmp and port range shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with icmp and port range
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  port_range_maximum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=0  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

UpdatePrivacyPolicy - update with minport>maxport shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with minport>maxport
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

UpdatePrivacyPolicy - update with policy not found shall return error
   [Documentation]
   ...  send UpdatePrivacyPolicy with a policy that does not exist 
   ...  verify error is returned

   ${name}=  Get Default Privacy Policy Name
   ${dev}=   Get Default Developer Name


   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"${dev}\\\\",\\\\"name\\\\":\\\\"${name}\\\\"} not found"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

UpdatePrivacyPolicy - updating a policy in use by a cluster shall return error
   [Documentation]
   ...  create a clusterinst pointing to a privacy policy
   ...  send UpdatePrivacyPolicy to the policy 
   ...  verify error is returned 
   #EDGECLOUD-1936 - Privacy Policy - should disallow a policy update if in use by a cluster instance
   Create Flavor  region=${region}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=11  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Update not allowed because policy in use by Cluster Inst"}')  Update Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

