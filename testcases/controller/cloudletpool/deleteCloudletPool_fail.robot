*** Settings ***
Documentation  DeleteCloudletPool failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-1689
DeleteCloudletPool - delete without region shall return error 
   [Documentation]
   ...  - send DeleteCloudletPool without region 
   ...  - verify proper error is received 

   #EDGECLOUD-1741 - DeleteCloudletPool without parms gives wrong message

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-1690
DeleteCloudletPool - delete without parameters shall return error
   [Documentation] 
   ...  - send DeleteCloudletPool with region only
   ...  - verify proper error is received

   #EDGECLOUD-1741 - DeleteCloudletPool without parms gives wrong message

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {} not found"}

# ECQ-1691
DeleteCloudletPool - delete with name not found shall return error
   [Documentation]
   ...  - send DeleteCloudletPool for policy not found
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  token=${token}  cloudlet_pool_name=xpoolx  operator_org_name=tmus

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"tmus\\\\",\\\\"name\\\\":\\\\"xpoolx\\\\"} not found"}

# orgcloudletpool not supported
# ECQ-1692
#DeleteCloudletPool - delete when assinged to an org shall return error 
#   [Documentation]
#   ...  - send CreateCloudletPool
#   ...  - assign via orgcloudletpool create
#   ...  - send DeleteCloudletPool
#   ...  - verify proper error is received
#
#   #EDGECLOUD-1728 able to do DeleteCloudletPool when the pool is assigned to an org  closed
#   # EDGECLOUD-3401 able to do DeleteCloudletPool when the pool is assigned to an org
#
#   ${pool_name}=  Get Default Cloudlet Pool Name
#   ${org_name}=   Get Default Organization Name
#
#   Create Org
#
#   ${pool_return1}=  Create Cloudlet Pool  region=US  
#   log to console  xxx ${pool_return1}
#
#   ${pool_return}=  Create Org Cloudlet Pool  region=US  
#
#   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  
#
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Cannot delete CloudletPool region US name ${pool_name} because it is in use by OrgCloudletPool org ${org_name}"}

# ECQ-3310
DeleteCloudletPool - delete when assigned to an invitation/response shall return error
   [Documentation]
   ...  - send CreateCloudletPool
   ...  - create invitation and response
   ...  - send DeleteCloudletPool
   ...  - verify proper error is received

   [Tags]  CloudletPoolAccess

   ${pool_name}=  Get Default Cloudlet Pool Name
   ${org_name}=   Get Default Organization Name

   Create Org  orgtype=operator

   ${pool_return1}=  Create Cloudlet Pool  region=US  token=${token}

   Create Cloudlet Pool Access Invitation    region=${region}    token=${token}

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  token=${token}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cannot delete CloudletPool region ${region} name ${pool_name} because it is referenced by automation_dev_org invitation"}

   Create Cloudlet Pool Access Response  region=${region}  decision=accept   token=${token}

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=US  token=${token}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Cannot delete CloudletPool region ${region} name ${pool_name} because it is referenced by automation_dev_org invitation, automation_dev_org response"}

# ECQ-4185
DeleteCloudletPool - delete when assigned to a trustpolicy exception shall return error
   [Documentation]
   ...  - send CreateCloudletPool
   ...  - create TrustPolicyException with the cloudletpool
   ...  - send DeleteCloudletPool
   ...  - verify proper error is received

   [Tags]  TrustPolicyException 

   ${pool_name}=  Get Default Cloudlet Pool Name
   ${policy_name}=   Get Default Trust Policy Name

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rule_list}  use_defaults=${False}

   ${error}=  Run Keyword And Expect Error  *   Delete Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool in use by Trust Policy Exception {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"}"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
