*** Settings ***
Documentation  DeleteCloudletPool

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Suite Setup  Setup
#Suite Teardown  Cleanup Provisioning

*** Test Cases ***
DeleteCloudletPool - deleting cloudlet pool shall delete all cloudlet pool members 
   [Documentation]
   ...  send CreateCloudletPool
   ...  send CreateCloudletPoolMembers 
   ...  send DeleteCloudletPool
   ...  verify all members are deleted 

   ${token}=  Get Super Token
   ${pool_name}=  Get Default Cloudlet Pool Name

   Create Cloudlet Pool         region=US  cloudlet_pool_name=${pool_name}  auto_delete=${False}
   Create Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  operator_name=tmus  cloudlet_name=tmocloud-1  auto_delete=${False}
   Create Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  operator_name=tmus  cloudlet_name=tmocloud-2  auto_delete=${False}

   ${show_return}=   Show Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  token=${token}  use_defaults=${False} 
   Length Should Be   ${show_return}  2

   # delete the pool 
   Delete Cloudlet Pool         region=US 

   ${show_return_post}=   Show Cloudlet Pool Member  region=US  cloudlet_pool_name=${pool_name}  token=${token}  use_defaults=${False}
   Length Should Be   ${show_return_post}  0

