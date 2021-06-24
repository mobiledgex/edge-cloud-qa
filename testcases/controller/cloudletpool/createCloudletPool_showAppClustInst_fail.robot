*** Settings ***
Documentation  Show Cluster/AppInst fail as Operator

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  dmuus
${region}=  US

*** Test Cases ***
# ECQ-3504
CreateCloudletPoolAccess - Operator shall not see developer cluster/appinst with no cloudlet in pool
   [Documentation]
   ...  - create cloudlet pool with no cloudlets
   ...  - create an invitation as opviewer
   ...  - create response/cluster/appinst as developer
   ...  - send ShowClusterInst and ShowAppInst as operator
   ...  - verify error is received

   [Tags]  CloudletPoolAccess

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   Create Billing Org  token=${super_token}

   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create App  region=${region}  access_ports=tcp:1  token=${devman_token}
   ${c}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   ${ac}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   ${ap}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}
   ${publicc}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=tmocloud-2  developer_org_name=${devorg1}
   ${publica}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=tmocloud-2  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cluster Instances  region=${region}  token=${op_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show App Instances  region=${region}  token=${op_token}  use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cluster Instances  region=${region}  token=${opcon_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show App Instances  region=${region}  token=${opcon_token}  use_defaults=${False}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show Cluster Instances  region=${region}  token=${opview_token}  use_defaults=${False}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Show App Instances  region=${region}  token=${opview_token}  use_defaults=${False}

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

   #@{cloudlet_list}=  Create List  ${cloudlet_name_fake}
   Create Cloudlet Pool  region=${region}  token=${op_token}  operator_org_name=${organization}  #cloudlet_list=${cloudlet_list}

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${pool_name}
   Set Suite Variable  ${op_token}
   Set Suite Variable  ${opcon_token}
   Set Suite Variable  ${opview_token}
   Set Suite Variable  ${devman_token}
   Set Suite Variable  ${devcon_token}

