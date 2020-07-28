*** Settings ***
Documentation  CreatePrivacyPolicy failures

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
CreatePrivacyPolicy - create without region shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without region
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no region specified"}')  Create Privacy Policy  token=${token}  use_defaults=${False}

CreatePrivacyPolicy - create without token shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without token
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Create Privacy Policy  region=${region}  use_defaults=${False}

CreatePrivacyPolicy - create without parms shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with no parms 
   ...  verify error is returned 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid organization, name cannot be empty"}')  Create Privacy Policy  region=${region}  token=${token}  use_defaults=${False}

CreatePrivacyPolicy - create without policy name shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with no policy name 
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy name cannot be empty"}')  Create Privacy Policy  developer_org_name=${developer}  region=${region}  token=${token}  use_defaults=${False}

CreatePrivacyPolicy - create with unknown org name shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with unknown org name
   ...  verify error is returned

   #Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Privacy Policy  developer_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"org xxxx not found"}')  Create Privacy Policy  developer_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}

CreatePrivacyPolicy - create without developer name shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with no developer name
   ...  verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid organization, name cannot be empty"}')  Create Privacy Policy  policy_name=x  region=${region}  token=${token}  use_defaults=${False}

CreatePrivacyPolicy - create without protocol shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy without protocol
   ...  verify error is returned

   &{rule}=  Create Dictionary  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Create Privacy Policy  region=${region}  rule_list=${rulelist} 

#CreatePrivacyPolicy - create without min port range shall return error
#   [Documentation]
#   ...  send CreatePrivacyPolicy without min port 
#   ...  verify error is returned
#   
#   &{rule}=  Create Dictionary  protocol=tcp 
#   @{rulelist}=  Create List  ${rule}
#
#   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

CreatePrivacyPolicy - create with invalid CIDR shall return error 
   [Documentation]
   ...  send CreatePrivacyPolicy with invalid CIDR 
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=x 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: x"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=256.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 256.1.1.1/1"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1/33
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1/33"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: "}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

CreatePrivacyPolicy - create with invalid minport shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with invalid min port 
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=string, field=port_range_min, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=number -1, field=port_range_min, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 65536"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

CreatePrivacyPolicy - create with invalid maxport shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with invalid max port
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=string, field=port_range_max, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid POST data, Unmarshal type error: expected=uint32, got=number -1, field=port_range_max, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid max port range: 65536"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

CreatePrivacyPolicy - create with icmp and port range shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with icmp and port range
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  port_range_maximum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=0  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

CreatePrivacyPolicy - create with minport>maxport shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with minport>maxport
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

CreatePrivacyPolicy - create with duplicate policy shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy twice 
   ...  verify error is returned

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=11  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${policyname}=  Get Default Privacy Policy Name
   ${developer}=  Get Default Developer Name

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Key {\\\\"organization\\\\":\\\\"${developer}\\\\",\\\\"name\\\\":\\\\"${policyname}\\\\"} already exists"}')  Create Privacy Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-1820
CreatePrivacyPolicy - CreateClusterInst with k8s shared shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with k8s shared 
   ...  verify error is returned

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   Create Flavor  region=${region}
   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   Should Contain  ${error}  ('code=400', 'error={"message":"IpAccessShared not supported for privacy policy enabled cluster"}')

CreatePrivacyPolicy - CreateClusterInst with azure shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with azure
   ...  verify error is returned

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   Should Contain  ${error}  ('code=400', 'error={"message":"Privacy Policy not supported on PLATFORM_TYPE_AZURE"}')

CreatePrivacyPolicy - CreateClusterInst with gcp shall return error
   [Documentation]
   ...  send CreatePrivacyPolicy with gcp
   ...  verify error is returned

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_gcp}  operator_org_name=${operator_name_gcp}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   Should Contain  ${error}  ('code=400', 'error={"message":"Privacy Policy not supported on PLATFORM_TYPE_GCP"}') 

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

