*** Settings ***
Documentation  Show Cluster/AppInst as Operator

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  tmus
${region}=  US

*** Test Cases ***
# ECQ-3408
CreateCloudletPoolAccess - OperatorManager shall be able to see developer cluster/appinst
   [Documentation]
   ...  - create an invitation as opmanager
   ...  - create response/cluster/appinst as developer
   ...  - send ShowClusterInst and ShowAppInst as opmanager
   ...  - verify it only shows clusters/apps from the cloudlet in the pool

   [Tags]  CloudletPoolAccess

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create App  region=${region}  access_ports=tcp:1  token=${devman_token}
   ${c}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   ${ac}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   ${ap}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}
   ${publicc}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=tmocloud-2  developer_org_name=${devorg1}
   ${publica}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=tmocloud-2  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}
 
   @{pools}=  Show Cloudlet Pool  region=${region}  token=${op_token}  use_defaults=${False}
   @{cloudlet_list}=  Get Cloudlets From Pools  ${pools}

   Show Cloudlet Pool Access Granted  region=${region}  token=${op_token}
   @{cluster_list}=  Show Cluster Instances  region=${region}  token=${op_token}  use_defaults=${False}
   Should Be True  len(@{cluster_list}) >= 2
   @{app_list}=  Show App Instances  region=${region}  token=${op_token}  use_defaults=${False}
   Should Be True  len(@{app_list}) >= 2

   Clusters Should Only Contain Cloudlets From Pools  ${cluster_list}  ${cloudlet_list}
   Apps Should Only Contain Cloudlets From Pools  ${app_list}  ${cloudlet_list}
 
   Cluster Should Be In List  ${cluster_list}  ${c['data']['key']['cluster_key']['name']}
   Cluster Should Be In List  ${cluster_list}  ${ac['data']['real_cluster_name']}

   App Should Be In List  ${app_list}  ${ac['data']['key']['app_key']['name']}
   App Should Be In List  ${app_list}  ${ap['data']['key']['app_key']['name']}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Cluster Instance  region=${region}  token=${op_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}  token=${op_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}  token=${op_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}r

# ECQ-3409
CreateCloudletPoolAccess - OperatorContributor shall be able to see developer cluster/appinst
   [Documentation]
   ...  - create an invitation as opcontributor
   ...  - create response/cluster/appinst as developer
   ...  - send ShowClusterInst and ShowAppInst as opcontributor
   ...  - verify it only shows clusters/apps from the cloudlet in the pool

   [Tags]  CloudletPoolAccess

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create Cloudlet Pool Access Invitation  region=${region}  token=${opcon_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create App  region=${region}  access_ports=tcp:1  token=${devman_token}
   ${c}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   ${ac}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   ${ap}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}
   ${publicc}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=tmocloud-2  developer_org_name=${devorg1}
   ${publica}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=tmocloud-2  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}

   @{pools}=  Show Cloudlet Pool  region=${region}  token=${opcon_token}  use_defaults=${False}
   @{cloudlet_list}=  Get Cloudlets From Pools  ${pools}

   Show Cloudlet Pool Access Granted  region=${region}  token=${opcon_token}
   @{cluster_list}=  Show Cluster Instances  region=${region}  token=${opcon_token}  use_defaults=${False}
   Should Be True  len(@{cluster_list}) >= 2
   @{app_list}=  Show App Instances  region=${region}  token=${opcon_token}  use_defaults=${False}
   Should Be True  len(@{app_list}) >= 2

   Clusters Should Only Contain Cloudlets From Pools  ${cluster_list}  ${cloudlet_list}
   Apps Should Only Contain Cloudlets From Pools  ${app_list}  ${cloudlet_list}

   Cluster Should Be In List  ${cluster_list}  ${c['data']['key']['cluster_key']['name']}
   Cluster Should Be In List  ${cluster_list}  ${ac['data']['real_cluster_name']}

   App Should Be In List  ${app_list}  ${ac['data']['key']['app_key']['name']}
   App Should Be In List  ${app_list}  ${ap['data']['key']['app_key']['name']}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Cluster Instance  region=${region}  token=${opcon_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}  token=${opcon_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}  token=${opcon_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}

# ECQ-3410
CreateCloudletPoolAccess - OperatorViewer shall be able to see developer cluster/appinst
   [Documentation]
   ...  - create an invitation as opviewer
   ...  - create response/cluster/appinst as developer
   ...  - send ShowClusterInst and ShowAppInst as opviewer
   ...  - verify it only shows clusters/apps from the cloudlet in the pool

   [Tags]  CloudletPoolAccess

   ${devorg1}=  Create Org  token=${super_token}  orgtype=developer
   Adduser Role  token=${super_token}  orgname=${devorg1}  username=${dev_manager_user_automation}  role=DeveloperManager

   Create Cloudlet Pool Access Invitation  region=${region}  token=${op_token}  cloudlet_pool_name=${pool_name}  cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}
   Create Cloudlet Pool Access Response  region=${region}  token=${devman_token}  cloudlet_pool_name=${pool_name}   cloudlet_pool_org_name=${organization}  developer_org_name=${devorg1}  decision=accept

   Create App  region=${region}  access_ports=tcp:1  token=${devman_token}
   ${c}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   ${ac}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   ${ap}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}
   ${publicc}=  Create Cluster Instance  region=${region}  token=${devman_token}  operator_org_name=${organization}  cloudlet_name=tmocloud-2  developer_org_name=${devorg1}
   ${publica}=  Create App Instance  region=${region}  token=${devman_token}  developer_org_name=${devorg1}  cloudlet_name=tmocloud-2  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}

   @{pools}=  Show Cloudlet Pool  region=${region}  token=${opview_token}  use_defaults=${False}
   @{cloudlet_list}=  Get Cloudlets From Pools  ${pools}

   Show Cloudlet Pool Access Granted  region=${region}  token=${opview_token}
   @{cluster_list}=  Show Cluster Instances  region=${region}  token=${opview_token}  use_defaults=${False}
   Should Be True  len(@{cluster_list}) >= 2
   @{app_list}=  Show App Instances  region=${region}  token=${opview_token}  use_defaults=${False}
   Should Be True  len(@{app_list}) >= 2

   Clusters Should Only Contain Cloudlets From Pools  ${cluster_list}  ${cloudlet_list}
   Apps Should Only Contain Cloudlets From Pools  ${app_list}  ${cloudlet_list}

   Cluster Should Be In List  ${cluster_list}  ${c['data']['key']['cluster_key']['name']}
   Cluster Should Be In List  ${cluster_list}  ${ac['data']['real_cluster_name']}

   App Should Be In List  ${app_list}  ${ac['data']['key']['app_key']['name']}
   App Should Be In List  ${app_list}  ${ap['data']['key']['app_key']['name']}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Cluster Instance  region=${region}  token=${opview_token}  operator_org_name=${organization}  cloudlet_name=${cloudlet_name_fake}  developer_org_name=${devorg1}
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}  token=${opview_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_name=autocluster33
   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete App Instance  region=${region}  token=${opview_token}  developer_org_name=${devorg1}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${organization}  cluster_instance_developer_org_name=${devorg1}

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

Cluster Should Be In List
   [Arguments]  ${cluster_list}  ${cluster_name}

   ${found}=  Set Variable  ${False}
   FOR  ${cluster}  IN  @{cluster_list}
      IF  "${cluster['data']['key']['cluster_key']['name']}" == '${cluster_name}'
         ${found}=  Set Variable  ${True}
         Exit For Loop
      END
   END

   Run Keyword If  ${found} == ${False}  Fail  Cluster ${cluster_name} not found

Get Cloudlets From Pools
   [Arguments]  ${pools}

   @{cloudlet_list}=  Create List
   FOR  ${pool}  IN  @{pools}
      IF  'cloudlets' in ${pool['data']}
         FOR  ${cloud}  IN  @{pool['data']['cloudlets']}
            Append To List  ${cloudlet_list}  ${cloud}
         END
      END
   END

   [Return]  @{cloudlet_list}

Clusters Should Only Contain Cloudlets From Pools
   [Arguments]  ${cluster_list}  ${cloudlet_list}

   FOR  ${cluster}  IN  @{cluster_list}
      IF  "${cluster['data']['key']['cloudlet_key']['name']}" not in @{cloudlet_list}
         Fail  Cloudlet ${cluster['data']['key']['cloudlet_key']['name']} not in list ${cloudlet_list}
      END
   END

Apps Should Only Contain Cloudlets From Pools
   [Arguments]  ${app_list}  ${cloudlet_list}

   FOR  ${app}  IN  @{app_list}
      IF  "${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']}" not in @{cloudlet_list}
         Fail  Cloudlet ${app['data']['key']['cluster_inst_key']['cloudlet_key']['name']} not in list ${cloudlet_list}
      END
   END

App Should Be In List
   [Arguments]  ${app_list}  ${app_name}

   ${found}=  Set Variable  ${False}
   FOR  ${app}  IN  @{app_list}
      IF  "${app['data']['key']['app_key']['name']}" == '${app_name}'
         ${found}=  Set Variable  ${True}
         Exit For Loop
      END
   END

   Run Keyword If  ${found} == ${False}  Fail  App ${app_name} not found

