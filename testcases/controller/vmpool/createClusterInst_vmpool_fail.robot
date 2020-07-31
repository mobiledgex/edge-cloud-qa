*** Settings ***
Documentation  DeleteVMPool failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_name_vmpool}=  TDG
${vmpool_server_name}=  vmpoolvm
${physical_name}=  berlin

${cloudlet_name_vmpool}=  cloudlet1595967146-891194
${vmpool_name}=  vmpool1595967146-891194

${region}=  US

*** Test Cases ***
ClusterInst shall fail with VMPool IpAccessDedicated/docker and over large flavor
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=docker  

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')

ClusterInst shall fail with VMPool IpAccessShared/docker and over large flavor
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=docker

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}') 
  
ClusterInst shall fail with VMPool IpAccessShared/k8s and over large flavor
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=1

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')

ClusterInst shall create with VMPool IpAccessDedicated/k8s and over large flavor
   [Documentation]
   ...  send CreateVMPool
   ...  assign via orgcloudletpool create
   ...  send DeleteCloudletPool
   ...  verify proper error is received
   
   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=kubernetes  number_masters=1  number_nodes=1

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')
 
*** Keywords ***
Setup
   ${flavor_name}=  Get Default Flavor Name

   Create Flavor  region=${region}  ram=8192  vcpus=1  disk=1

   Set Suite Variable  ${flavor_name}
