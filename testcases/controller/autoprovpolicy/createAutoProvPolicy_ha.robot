*** Settings ***
Documentation  CreateAutoProvPolicy 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables **
${region}  US

*** Test Cases ***
CreateAutoProvPolicy - appinst should start when no appinst exists and max_instances=0
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1 
   ...  verify policy is created 

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudletlist}

   Create App  region=${region}  auto_prov_policy=${policy_name}  

   #Sleep  30 seconds
   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}
   
   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${app_name}

CreateAutoProvPolicy - appinst should start when no appinst exists and max_instances>0
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1
   ...  verify policy is created

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

   Create App  region=${region}  auto_prov_policy=${policy_name}

   #Sleep  30 seconds
   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${app_name}
   Should Be Equal  ${appinst['data']['key']['app_key']['organization']}  ${developer_name}
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['organization']}  ${developer_name} 
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  tmocloud-1 
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  tmus 
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  andyres


*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Auto Provisioning Policy Name
   ${app_name}=  Get Default App Name
   ${developer_name}=  Get Default Developer Name

   Create Flavor  region=${region}

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name}
