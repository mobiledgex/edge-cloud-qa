*** Settings ***
Documentation   CreateClusterInst with cloudlet maintenance failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${username}=   mextester06
${password}=   ${mextester06_gmail_password}

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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  token=${tokendev}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  token=${tokendev}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  token=${tokendev}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  token=${tokendev}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  token=${tokendev}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  token=${tokendev}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  token=${tokendev}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  token=${tokendev}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  reservable=${True}  token=${token}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  reservable=${True}  token=${token}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared  reservable=${True}  token=${token}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}  token=${token}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}  token=${token}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated  reservable=${True}  token=${token}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  reservable=${True}  token=${token}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  reservable=${True}  token=${token}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5  token=${token}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  reservable=${True}  token=${token}
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

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  reservable=${True}  token=${token}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  reservable=${True}  token=${token}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg2}=  Run Keyword And Expect Error  *  Update Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  number_nodes=5  token=${token}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}
   ${error_msg3}=  Run Keyword And Expect Error  *  Create Cluster Instance  region=${region}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  reservable=${True}  token=${token}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   Create Flavor  region=${region}

   Create Org  orgtype=operator
   RestrictedOrg Update
   Create Cloudlet  region=${region} 

   ${operator_name}=  Get Default Organization Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${flavor_name_default}=  Get Default Flavor Name
   ${org_name_dev}=  Set Variable  ${operator_name}_dev

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com
   ${usernamedev_epoch}=  Catenate  SEPARATOR=  ${username}  dev  ${epoch}
   ${emaildev}=  Catenate  SEPARATOR=  ${username}  dev  +  ${epoch}  @gmail.com

   Create Org  orgname=${org_name_dev}  orgtype=developer
   Create Billing Org  billing_org_name=${org_name_dev}  token=${token}  
   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name}  role=OperatorManager
   Adduser Role  username=${usernamedev_epoch}  orgname=${org_name_dev}  role=DeveloperManager

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=${usernamedev_epoch}  password=${password}

   Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${tokendev}
   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${org_name_dev}

Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Cleanup Provisioning

