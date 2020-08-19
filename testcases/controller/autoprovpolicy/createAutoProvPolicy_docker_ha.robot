*** Settings ***
Documentation  CreateAutoProvPolicy 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables **
${region}  US

*** Test Cases ***
CreateAutoProvPolicy - appinst should start when no appinst exists and max_instances=0 with cluster=docker/dedicated and app=docker/lb
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1 
   ...  verify policy is created 

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudletlist}

   Create Cluster Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=tmus  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}

   Create App  region=${region}  auto_prov_policy=${policy_name}  deployment=docker  access_type=loadbalancer 

   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}
   
   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${app_name}
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cluster_name}

CreateAutoProvPolicy - appinst should start when no appinst exists and max_instances=0 with cluster=docker/dedicated and app=docker/direct
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1
   ...  verify policy is created

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudletlist}

   Create Cluster Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=tmus  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}

   Create App  region=${region}  auto_prov_policy=${policy_name}  deployment=docker  access_type=direct

   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${app_name}
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cluster_name}

CreateAutoProvPolicy - appinst should start when no appinst exists and max_instances=0 with cluster=docker/shared and app=docker/lb
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1
   ...  verify policy is created

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=1  max_instances=0  cloudlet_list=${cloudletlist}

   Create Cluster Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=tmus  deployment=docker  ip_access=IpAccessShared  reservable=${True}

   Create App  region=${region}  auto_prov_policy=${policy_name}  deployment=docker  access_type=loadbalancer

   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${app_name}
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cluster_name}

CreateAutoProvPolicy - 1 appinst should start when no appinst exists and max_instances>0
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1
   ...  verify policy is created

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

   Create Cluster Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=tmus  reservable=${True}

   Create App  region=${region}  auto_prov_policy=${policy_name}

   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}

   Should Be Equal  ${appinst['data']['key']['app_key']['name']}  ${app_name}
   Should Be Equal  ${appinst['data']['key']['app_key']['organization']}  ${developer_name}
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['organization']}  ${developer_name} 
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  tmocloud-1 
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  tmus 
   Should Be Equal  ${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cluster_name} 

CreateAutoProvPolicy - 2 appinst should start when no appinst exists and max_instances>0
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1
   ...  verify policy is created

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   &{cloudlet2}=  Create Dictionary  cloudlet_name=tmocloud-2  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}  ${cloudlet2}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  token=${token}  min_active_instances=2  max_instances=4  cloudlet_list=${cloudletlist}

   Create Cluster Instance  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=tmus  reservable=${True}
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}2  cloudlet_name=tmocloud-2  operator_org_name=tmus  reservable=${True}

   Create App  region=${region}  auto_prov_policy=${policy_name}

   ${appinst}=  Show App Instance  region=${region}  app_name=${app_name}

   Should Be Equal  ${appinst[0]['data']['key']['app_key']['name']}  ${app_name}
   Should Be Equal  ${appinst[0]['data']['key']['app_key']['organization']}  ${developer_name}
   Should Be Equal  ${appinst[0]['data']['key']['cluster_inst_key']['organization']}  ${developer_name}
   Should Be Equal  ${appinst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  tmocloud-1
   Should Be Equal  ${appinst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  tmus
   Should Be Equal  ${appinst[0]['data']['key']['cluster_inst_key']['cluster_key']['name']}  ${cluster_name}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Auto Provisioning Policy Name
   ${app_name}=  Get Default App Name
   ${developer_name}=  Get Default Developer Name
   ${cluster_name}=  Get Default Cluster Name

   Create Flavor  region=${region}

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${cluster_name}
