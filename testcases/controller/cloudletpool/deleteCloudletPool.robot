*** Settings ***
Documentation  DeleteCloudletPool

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Suite Setup  Setup
#Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-1688
DeleteCloudletPool - deleting cloudlet pool shall delete all cloudlet pool members 
   [Documentation]
   ...  - send CreateCloudletPool
   ...  - send CreateCloudletPoolMembers 
   ...  - send DeleteCloudletPool
   ...  - verify all members are deleted 

   ${token}=  Get Super Token
   ${pool_name}=  Get Default Cloudlet Pool Name

   Create Cloudlet Pool         region=US  cloudlet_pool_name=${pool_name}  operator_org_name=tmus  auto_delete=${False}  token=${token}
   Add Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  operator_org_name=tmus  cloudlet_name=tmocloud-1  auto_delete=${False}  token=${token}
   Add Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  operator_org_name=tmus  cloudlet_name=tmocloud-2  auto_delete=${False}  token=${token}

   ${show_return}=   Show Cloudlet Pool  region=US  cloudlet_pool_name=${pool_name}  operator_org_name=tmus  token=${token}  use_defaults=${False} 
   Length Should Be   ${show_return[0]['data']['cloudlets']}  2

   # delete the pool 
   Delete Cloudlet Pool         region=US   cloudlet_pool_name=${pool_name}  operator_org_name=tmus  token=${token}

   ${show_return_post}=   Show Cloudlet Pool  region=US  cloudlet_pool_name=${pool_name}  operator_org_name=tmus  token=${token}  use_defaults=${False}
   Length Should Be  ${show_return_post}  0
