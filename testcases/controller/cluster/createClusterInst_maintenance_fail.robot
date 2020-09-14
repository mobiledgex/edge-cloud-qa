*** Settings ***
Documentation   CreateClusterInst with cloudlet maintenance failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-2542
ClusterInst - error shall be recieved when creating a docker/shared cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a docker/shared cluster instance on the cloudlet 
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a docker/shared cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a docker/shared cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2543
ClusterInst - error shall be recieved when creating a docker/dedicated cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a docker/dedicated cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a docker/dedicated cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a docker/dedicated cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2544
ClusterInst - error shall be recieved when creating a k8s/shared cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a k8s/shared cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a k8s/shared cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a k8s/shared cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5 
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2545
ClusterInst - error shall be recieved when creating a k8s/dedicated cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a k8s/dedicated cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a k8s/dedicated cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a k8s/dedicated cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5  
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2546
ClusterInst - error shall be recieved when creating a docker/shared reservable cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a docker/shared reservable cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a docker/shared reservable cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a docker/shared reservable cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  reservable=${True}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  reservable=${True}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  reservable=${True}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2547
ClusterInst - error shall be recieved when creating a docker/dedicated reservable cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a docker/dedicated reservable cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a docker/dedicated reservable cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a docker/dedicated reservable cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2548
ClusterInst - error shall be recieved when creating a k8s/shared reservable cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a k8s/shared reservable cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a k8s/shared reservable cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a k8s/shared reservable cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  reservable=${True}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  reservable=${True}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  reservable=${True}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2549
ClusterInst - error shall be recieved when creating a k8s/dedicated reservable cluster inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a k8s/dedicated reservable cluster instance on the cloudlet
   ...  - verify proper error is received
   ...  - put cloudlet in maintenance_state=NormalOperation
   ...  - create a k8s/dedicated reservable cluster instance on the cloudlet
   ...  - verify cluster is created
   ...  - put cloudlet in maintenance_state=MaintenanceStart
   ...  - create a k8s/dedicated reservable cluster instance on the cloudlet
   ...  - verify proper error is received

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  reservable=${True}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  reservable=${True}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  reservable=${True}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

*** Keywords ***
Setup
   Create Flavor  region=${region}

   Create Org
   Create Cloudlet  region=${region} 

   ${operator_name}=  Get Default Organization Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${flavor_name_default}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator_name}
   Set Suite Variable  ${cloudlet_name}

Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
   Cleanup Provisioning

