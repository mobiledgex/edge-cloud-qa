*** Settings ***
Documentation  CreateCloudletPool Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${operator}=  tmus

*** Test Cases ***
# ECQ-1669
CreateCloudletPool - create without region shall return error
   [Documentation]
   ...  - send CreateCloudletPool without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-1670
CreateCloudletPool - create without parameters shall return error
   [Documentation]
   ...  - send CreateCloudletPool with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-2271
CreateCloudletPool - create without pool name shall return error
   [Documentation]
   ...  - send CreateCloudletPool with org only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=US  operator_org_name=TDG  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

# ECQ-1671
CreateCloudletPool - create with invalid pool name shall fails 
   [Documentation]
   ...  - send CreateCloudletPool with invalid name
   ...  - verify proper error is received 

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=-pool  operator_org_name=TDG

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # $ in name 
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=p$ool  operator_org_name=TDG

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # () in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=p(o)ol  operator_org_name=TDG

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # +={}<> in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=+={}<>  operator_org_name=TDG

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

# ECQ-1672
CreateCloudletPool - create with same name shall return error
   [Documentation]
   ...  - send CreateCloudletPool twice for same name 
   ...  - verify proper error is received

   Run Keyword and Ignore Error  Delete Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  operator_org_name=TDG
   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  operator_org_name=TDG  use_defaults=False

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=mypoool  operator_org_name=TDG  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"TDG\\\\",\\\\"name\\\\":\\\\"mypoool\\\\"} already exists"}

# ECQ-3753
CreateCloudletPool - creating with cloudletlist with appinst shall return error
   [Documentation]
   ...  - create a cloudlet and appinst
   ...  - send CreateCloudletPool to add the cloudlet
   ...  - verify proper error is received
   ...  - delete the appinst
   ...  - send CreateCloudletPool and verify it is added

   ${cloudlet_name}=  Get Default Cloudlet Name

   Create Cloudlet  region=US  token=${token}  operator_org_name=tmus

   Create Flavor  region=${region}
   Create App  region=${region}  access_ports=tcp:1  token=${token}
   ${ap}=  Create App Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_instance_name=autoclusterxx  auto_delete=${False}

   ${clist}=  Create List  ${cloudlet_name}
   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${token}  operator_org_name=${operator}  cloudlet_list=${clist}

   Delete App Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_instance_name=autoclusterxx
   Delete Cluster Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_name=${ap['data']['real_cluster_name']}  developer_org_name=MobiledgeX

   Create Cloudlet Pool  region=${region}  token=${token}  operator_org_name=${operator}  cloudlet_list=${clist}

   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cannot create CloudletPool with cloudlet ${cloudlet_name} with existing developer automation_dev_org ClusterInsts or AppInsts. To include them as part of the pool, first create an empty pool, invite the developer to the pool, then add the cloudlet to the pool."}

# ECQ-3754
CreateCloudletPool - creating with cloudletlist with clusterinst shall return error
   [Documentation]
   ...  - create a cloudlet and clusterinst
   ...  - send CreateCloudletPool to add the cloudlet
   ...  - verify proper error is received
   ...  - delete the clusterinst
   ...  - send CreateCloudletPool and verify it is added

   ${cloudlet_name}=  Get Default Cloudlet Name

   Create Cloudlet  region=US  token=${token}  operator_org_name=tmus

   Create Flavor  region=${region}
   Create Cluster Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_name=xxxxxx  auto_delete=${False}

   ${clist}=  Create List  ${cloudlet_name}
   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${token}  operator_org_name=${operator}  cloudlet_list=${clist}

   Delete Cluster Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_name=xxxxxx

   Create Cloudlet Pool  region=${region}  token=${token}  operator_org_name=${operator}  cloudlet_list=${clist}

   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cannot create CloudletPool with cloudlet ${cloudlet_name} with existing developer automation_dev_org ClusterInsts or AppInsts. To include them as part of the pool, first create an empty pool, invite the developer to the pool, then add the cloudlet to the pool."}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
