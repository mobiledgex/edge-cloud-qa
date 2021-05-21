*** Settings ***
Documentation  CreateCloudletPoolAccess Invitation/Response for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  dmuus
${region}=  US

*** Test Cases ***
# ECQ-3411
CreateCloudletPoolAccess - DeveloperManager shall not be able to create clusterinst/appinst without an invite
   [Documentation]
   ...  - send CreateClusterInst for DeveloperManager without an invite
   ...  - verify proper error is received
   ...  - send CreateAppInst without an invite
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${developer_org_name_automation}  token=${devman_token}

   Create App  region=${region}  developer_org_name=${developer_org_name_automation}  access_ports=tcp:1  token=${devman_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${devman_token}

# ECQ-3412
CreateCloudletPoolAccess - DeveloperContributor shall not be able to create clusterinst/appinst without an invite
   [Documentation]
   ...  - send CreateClusterInst for DeveloperContributor without an invite
   ...  - verify proper error is received
   ...  - send CreateAppInst without an invite
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${developer_org_name_automation}  token=${devcon_token}

   Create App  region=${region}  developer_org_name=${developer_org_name_automation}  access_ports=tcp:1  token=${devcon_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${devcon_token}

# ECQ-3413
CreateCloudletPoolAccess - DeveloperManager shall not be able to create clusterinst/appinst without accept
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify error
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send CreateCloudletPoolAccessResponse with accept for org2
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  #developer_org_name=${developer_org_name_automation}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg2}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3414
CreateCloudletPoolAccess - DeveloperContributor shall not be able to create clusterinst/appinst without accept
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify error
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send CreateCloudletPoolAccessResponse with accept for org2
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devcon_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  #developer_org_name=${developer_org_name_automation}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg2}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3415
CreateCloudletPoolAccess - DeveloperManager shall not be able to create clusterinst/appinst after reject
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateCloudletPoolAccessResponse with reject for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify error
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send CreateCloudletPoolAccessResponse with accept for org2
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  #developer_org_name=${developer_org_name_automation}
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=reject  auto_delete=${False}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

   Delete Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg2}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3416
CreateCloudletPoolAccess - DeveloperContributor shall not be able to create clusterinst/appinst after reject
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateCloudletPoolAccessResponse with reject for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify error
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send CreateCloudletPoolAccessResponse with accept for org2
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  #developer_org_name=${developer_org_name_automation}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=reject  auto_delete=${False}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

   Delete Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg2}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3417
CreateCloudletPoolAccess - DeveloperManager shall not be able to create clusterinst/appinst after response delete
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send DeleteCloudletPoolAccessResponse for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  #developer_org_name=${developer_org_name_automation}
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept  auto_delete=${False}

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   Delete Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3418
CreateCloudletPoolAccess - DeveloperContributor shall not be able to create clusterinst/appinst after response delete
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send DeleteCloudletPoolAccessResponse for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  #developer_org_name=${developer_org_name_automation}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept  auto_delete=${False}

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   Delete Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3419
CreateCloudletPoolAccess - DeveloperManager shall not be able to create clusterinst/appinst after invite delete
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send DeleteCloudletPoolAccessInvite for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  auto_delete=${False}
   Create Cloudlet Pool Access Response  region=${region}  token=${dev_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept  auto_delete=${False}

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   Delete Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

# ECQ-3420
CreateCloudletPoolAccess - DeveloperContributor shall not be able to create clusterinst/appinst after invite delete
   [Documentation]
   ...  - create 2 orgs
   ...  - send CreateCloudletPoolAccessInvitation for org1
   ...  - send CreateCloudletPoolAccessResponse with accept for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify success
   ...  - send DeleteCloudletPoolAccessInvite for org1
   ...  - send CreateClusterInst/AppInst for org1
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${dev_token}=  Set Variable  ${devman_token}

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   ${devorg2}=  Create Org  token=${super_token}  orgname=${devorg1}2  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg2}  username=${dev_contributor_user_automation}  role=DeveloperContributor
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create App  region=${region}  developer_org_name=${devorg1}  access_ports=tcp:1  token=${dev_token}

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  auto_delete=${False}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept  auto_delete=${False}

   Create Cluster Instance  region=${region}  token=${dev_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Create App Instance  region=${region}  token=${dev_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}  #cluster_instance_name=autocluster33  token=${dev_token}

   Delete Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}

   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Cluster Instance  region=${region}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}  token=${dev_token}
   RunKeyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33  token=${dev_token}

*** Keywords ***
Setup
   ${super_token}=  Get Super Token

   ${pool_name}=  Get Default Cloudlet Pool Name

   Create Flavor  region=${region}  token=${super_token}

   ${op_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
   ${opcon_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}
   ${opview_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

   ${devman_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${devcon_token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

   @{cloudlet_list}=  Create List  ${cloudlet_name_fake}
   Create Cloudlet Pool  region=${region}  token=${op_token}  operator_org_name=${organization}  cloudlet_list=${cloudlet_list}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${op_token}
   Set Suite Variable  ${opcon_token}
   Set Suite Variable  ${opview_token}
   Set Suite Variable  ${devman_token}
   Set Suite Variable  ${devcon_token}

