*** Settings ***
Documentation   clustersage Fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationSunnydaleCloudletStage
${operator}=                       GDDT
${region}=  US

*** Test Cases ***
# ECQ-4317
ClusterUsage - get with no cluster org shall return error
   [Documentation]
   ...  - get clusterusage with no cluster org
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Must provide either Cluster organization or Cloudlet organization"}

# ECQ-4318
ClusterUsage - developer get with no cluster org shall return error
   [Documentation]
   ...  - get clusterusage with no app org as developer
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  operator_org_name=${operator}  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${dev_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Developers please specify the Cluster Organization"}

# ECQ-4319
ClusterUsage - operator get with no cloudlet org shall return error
   [Documentation]
   ...  - get clusterusage with no cloudlet org as operator
   ...  - verify error

   ${cloudlet_name}=  Get Default Cloudlet Name
   Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}

   @{cloudlet_list}=  Create List  ${cloudlet_name}
   ${pool_return}=  Create Cloudlet Pool  region=${region}  token=${op_manager_token}  operator_org_name=${operator_name_fake}  cloudlet_list=${cloudlet_list}
   Create Cloudlet Pool Access Invitation  region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}  token=${op_manager_token}
   Create Cloudlet Pool Access Response    region=${region}  cloudlet_pool_name=${pool_return['data']['key']['name']}  cloudlet_pool_org_name=${operator_name_fake}  developer_org_name=${developer_org_name_automation}  decision=accept  token=${dev_manager_token}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  token=${op_manager_token}  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  developer_org_name=${developer_org_name_automation}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  developer_org_name=${developer_org_name_automation}  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  developer_org_name=${developer_org_name_automation}  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Operators please specify the Cloudlet Organization"}

# ECQ-4320
ClusterUsage - operator get with no cloudlet pools shall return error
   [Documentation]
   ...  - get clusterusage with no cloudlet pools as operator
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  developer_org_name=${operator}  operator_org_name=dmuus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  developer_org_name=${operator}  operator_org_name=dmuus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  developer_org_name=${operator}  operator_org_name=dmuus  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  token=${op_manager_token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No non-empty CloudletPools to show"}

# ECQ-4321
ClusterUsage - get with no token shall return error
   [Documentation]
   ...  - get clusterusage with no token
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  developer_org_name=developer  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No bearer token found"}

# ECQ-4322
ClusterUsage - get with invalid start time shall return error
   [Documentation]
   ...  - get clusterusage with invalid start time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-4323
ClusterUsage - get with invalid end time shall return error
   [Documentation]
   ...  - get clusterusage with invalid end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=2019-09-26T04:01:01  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"2019-09-26T04:01:01\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-4324
ClusterUsage - get with invalid start/end time shall return error
   [Documentation]
   ...  - get clusterusage with invalid start/end time
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  cloudlet_name=cloudlet  operator_org_name=operator  developer_org_name=developer  start_time=x  end_time=2019-09  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"Invalid JSON data: Unmarshal time \\\\"x\\\\" failed, valid values are RFC3339 format, i.e. \\\\"2006-01-02T15:04:05Z07:00\\\\""}

# ECQ-4325
ClusterUsage - get with cluster not found shall return an empty list
   [Documentation]
   ...  - get clusterusage with cluster not found
   ...  - verify empty list is returned

   ${metrics}=  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=GDDT  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Empty  ${metrics['data']}

# ECQ-4326
ClusterUsage - get with operator not found shall return an empty list
   [Documentation]
   ...  - get clusterusage with operator not found
   ...  - verify empty list is returned

   ${metrics}=  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=operator  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Empty  ${metrics['data']}

# ECQ-4327
ClusterUsage - get with cloudlet not found shall return an empty list
   [Documentation]
   ...  - get clusterusage with cloudlet not found
   ...  - verify empty list is returned

   ${metrics}=  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=GDDT  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Empty  ${metrics['data']}

# ECQ-4328
ClusterUsage - get without region shall return error
   [Documentation]
   ...  - get clusterusage without region 
   ...  - verify error

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Contain  ${error}  code=400
   Should Contain  ${error}  {"message":"No region specified"}

# ECQ-4329
ClusterUsage - get with invalid cluster/cloudlet shall return error
   [Documentation]
   ...  - get clusterusage with invalid cluster/cloudlet args
   ...  - verify error

   #${token}=  Get Token

   ${inject}=  Set Variable  \\'\\;drop measurment \"cloudlet-ipusage\"

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cluster_instance_name=${inject}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cluster"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cluster_instance_name=autoclusterautomation  cloudlet_name=${inject}  operator_org_name=${operator}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudlet"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  region=US  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${inject}  developer_org_name=mobiledgex  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid cloudletorg"}')

   ${error}=  Run Keyword and Expect Error  *  Get Cluster Usage  start_time=2006-01-02T15:04:05Z  end_time=2006-01-02T15:04:05Z  cluster_instance_name=autoclusterautomation  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_org_name=${operator}  developer_org_name=${inject}  token=${token}  use_defaults=${False}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid clusterorg"}')

*** Keywords ***
Setup
    ${token}=  Get Super Token

    ${dev_manager_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
    ${op_manager_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Set Suite Variable  ${token}
    Set Suite Variable  ${dev_manager_token}
    Set Suite Variable  ${op_manager_token}

