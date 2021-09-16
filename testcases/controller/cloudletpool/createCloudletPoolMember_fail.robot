*** Settings ***
Documentation  CreateCloudletPoolMemberMember Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator}=  tmus
${region}=  US

*** Test Cases ***
# ECQ-1660
CreateCloudletPoolMember - create without region shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  token=${token}  cloudlet_pool_name=xxxxxx  operator_org_name=tmus  cloudlet_name=tmocloud-2  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-1661
CreateCloudletPoolMember - create without parameters shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"CloudletPool key {} not found"}
   Should Contain   ${error}  error={"message":"Invalid Cloudlet name"}

# ECQ-2303
CreateCloudletPoolMember - create without org shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember with name only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Add Cloudlet Pool Member  region=US  cloudlet_pool_name=xxx  cloudlet_name=tmocloud-2  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"name\\\\":\\\\"xxx\\\\"} not found"}
   Should Contain   ${error}  error={"message":"Invalid organization name"}

# ECQ-3838
CreateCloudletPoolMember - create without cloudlet name shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember without cloudlet name
   ...  - verify proper error is received

   Create Cloudlet Pool  region=US  operator_org_name=tmus
   ${error}=  Run Keyword And Expect Error  *  Add Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  operator_org_name=tmus  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   #Should Contain   ${error}  error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"tmus\\\\"} not found"}
   Should Contain   ${error}  error={"message":"Invalid Cloudlet name"}

# ECQ-1662
# removed since it checks the pool name exists before adding member
#CreateCloudletPoolMember - create with invalid pool name shall return error 
#   [Documentation]
#   ...  send CreateCloudletPoolMember with invalid name
#   ...  verify proper error is received 
#
#   Create Cloudlet Pool  region=US  token=${token}
#
#   # start with a dash
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=-pool
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}
#
#   # $ in name 
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=p$ool
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}
#
#   # () in name
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=p(o)ol
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}
#
#   # +={}<> in name
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=+={}<>
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

# ECQ-1663
CreateCloudletPoolMember - create with same name shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember twice for same name 
   ...  - verify proper error is received

   #EDGECLOUD-1716 CreateCloudletPoolMember for duplicate create should return the member name in the error

   ${cloudlet_name}=  Get Default Cloudlet Name

   Create Cloudlet  region=US  token=${token}  operator_org_name=tmus

   Create Cloudlet Pool  region=US  token=${token}  operator_org_name=${operator}
   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cloudlet already part of pool"}

# ECQ-1664
CreateCloudletPoolMember - create operator not found shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember operator not found 
   ...  - verify proper error is received

   #EDGECLOUD-1717 - CreateCloudletPoolMember - create with unknown operator/cloudlet should give info in error message

   #Create Cloudlet Pool  region=US  token=${token}  operator_org_name=${operator}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=tmusxxx  cloudlet_name=tmocloud-1
  
   ${pool_name}=  Get Default Cloudlet Pool Name
 
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"CloudletPool key {\\\\"organization\\\\":\\\\"tmusxxx\\\\",\\\\"name\\\\":\\\\"${pool_name}\\\\"} not found"}

# ECQ-1665
CreateCloudletPoolMember - create cloudlet not found shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember cloudlet not found
   ...  - verify proper error is received

   #EDGECLOUD-1717 - CreateCloudletPoolMember - create with unknown operator/cloudlet should give info in error message

   Create Cloudlet Pool  region=US  token=${token}  operator_org_name=${operator}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=tmus  cloudlet_name=tmocloud-1xx
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cloudlet key {\\\\"organization\\\\":\\\\"tmus\\\\",\\\\"name\\\\":\\\\"tmocloud-1xx\\\\"} not found"}

# ECQ-3751
CreateCloudletPoolMember - adding cloudlet with appinst shall return error
   [Documentation]
   ...  - create a cloudlet and appinst
   ...  - send CreateCloudletPoolMember to add the cloudlet
   ...  - verify proper error is received
   ...  - delete the appinst
   ...  - send CreateCloudletPoolMember and verify it is added

   ${cloudlet_name}=  Get Default Cloudlet Name

   Create Cloudlet  region=US  token=${token}  operator_org_name=tmus

   Create Flavor  region=${region}
   Create App  region=${region}  access_ports=tcp:1  token=${token}
   ${ap}=  Create App Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_instance_name=autoclusterxx  auto_delete=${False}

   Create Cloudlet Pool  region=${region}  token=${token}  operator_org_name=${operator}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=${region}  token=${token}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}

   Delete App Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_instance_name=autoclusterxx
   Delete Cluster Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  cluster_name=${ap['data']['real_cluster_name']}  developer_org_name=MobiledgeX

   Add Cloudlet Pool Member  region=${region}  token=${token}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}

   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cannot add cloudlet ${cloudlet_name} to CloudletPool with existing developer automation_dev_org ClusterInsts or AppInsts which are not authorized to deploy to the CloudletPool. Please invite the developer first, or remove the developer from the Cloudlet."}

# ECQ-3752
CreateCloudletPoolMember - adding cloudlet with clusterinst shall return error
   [Documentation]
   ...  - create a cloudlet and clusterinst
   ...  - send CreateCloudletPoolMember to add the cloudlet
   ...  - verify proper error is received
   ...  - delete the clusterinst
   ...  - send CreateCloudletPoolMember and verify it is added

   ${cloudlet_name}=  Get Default Cloudlet Name

   Create Cloudlet  region=US  token=${token}  operator_org_name=tmus

   Create Flavor  region=${region}
   Create Cluster Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus  auto_delete=${False}

   Create Cloudlet Pool  region=${region}  token=${token}  operator_org_name=${operator}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=${region}  token=${token}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}

   Delete Cluster Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name}  operator_org_name=tmus
   Add Cloudlet Pool Member  region=${region}  token=${token}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}

   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cannot add cloudlet ${cloudlet_name} to CloudletPool with existing developer automation_dev_org ClusterInsts or AppInsts which are not authorized to deploy to the CloudletPool. Please invite the developer first, or remove the developer from the Cloudlet."}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
