*** Settings ***
Documentation  CreateClusterInst for VMPool failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  MobiledgeX
${operator_name_vmpool}=  GDDT
${vmpool_server_name}=  vmpoolvm
${physical_name}=  beacon

${cloudlet_name_vmpool}=  automationVMPoolCloudlet
${vmpool_name}=  vmpool1595967146-891194

${region}=  US

*** Test Cases ***
# ECQ-2362
ClusterInst shall fail with VMPool IpAccessDedicated/docker and over-large flavor
   [Documentation]
   ...  - IpAccessDedicated/docker CreateClusterInst with VMPool and a flavor larger than the pool
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=16384  vcpus=1  disk=1

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=docker  

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')

# ECQ-2363
ClusterInst shall fail with VMPool IpAccessShared/docker and over-large flavor
   [Documentation]
   ...  - IpAccessShared/docker CreateClusterInst with VMPool and a flavor larger than the pool
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=16384  vcpus=1  disk=1

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=docker

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}') 

# ECQ-2364  
ClusterInst shall fail with VMPool IpAccessShared/k8s and over-large flavor
   [Documentation]
   ...  - IpAccessShared/k8s CreateClusterInst with VMPool and a flavor larger than the pool
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=16384  vcpus=1  disk=1

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=1

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')

# ECQ-2365
ClusterInst shall fail with VMPool IpAccessDedicated/k8s and over-large flavor
   [Documentation]
   ...  - IpAccessDedicated/k8s CreateClusterInst with VMPool and a flavor larger than the pool
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=16384  vcpus=1  disk=1
   
   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=kubernetes  number_masters=1  number_nodes=1

   Should Be Equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')

# ECQ-2366
ClusterInst shall fail with VMPool IpAccessDedicated/k8s and too many nodes 
   [Documentation]
   ...  - IpAccessDedicated/k8s CreateClusterInst with VMPool and more nodes than available in the pool
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=1024  vcpus=1  disk=1

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=kubernetes  number_masters=1  number_nodes=10

   Should Contain  ${error}  Encountered failures: Create failed: Cluster VM create Failed: Failed to meet VM requirement, required VMs = 12, free VMs available = 4","code":400 

# ECQ-2367
ClusterInst shall fail with VMPool IpAccessShared/k8s and too many nodes
   [Documentation]
   ...  - IpAccessShared/k8s CreateClusterInst with VMPool and more nodes than available in the pool
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=1024  vcpus=1  disk=1

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=10

   Should Contain  ${error}  Encountered failures: Create failed: Cluster VM create Failed: Failed to meet VM requirement, required VMs = 11, free VMs available = 4","code":400

# ECQ-2430
ClusterInst shall fail with VMPool and privacy policy
   [Documentation]
   ...  - CreateClusterInst with VMPool and privacy policy
   ...  - verify proper error is received

   Create Flavor  region=${region}  ram=1024  vcpus=1  disk=1

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Privacy Policy  region=${region}  rule_list=${rulelist}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=1  privacy_policy=${policy_return['data']['key']['name']}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"Privacy Policy not supported on PLATFORM_TYPE_VM_POOL"}')

*** Keywords ***
Setup
   ${flavor_name}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name}
