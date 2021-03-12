*** Settings ***
Documentation  UpdateVMPool

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections
  
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-2393
UpdateVMPool - shall be able to update without VM list 
   [Documentation]
   ...  - send CreateVMPool with VMs 
   ...  - verify pool is created 
   ...  - send UpdateVMPool with empty VM list
   ...  - verify pool list is empty

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.12  internal_ip=2.2.2.1
   @{vmlist}=  Create List  ${vm1}

   ${name}=  Generate Random String  length=100

   ${pool_return}=  Create VM Pool  region=US  token=${token}  vm_pool_name=${name}  org_name=MobiledgeX  vm_list=${vmlist} 

   Should Be Equal  ${pool_return['data']['key']['name']}  ${name} 
   Should Be Equal  ${pool_return['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1

   @{vmlist_update}=  Create List

   ${update_return}=  Update VM Pool  region=US  token=${token}  vm_pool_name=${name}  org_name=MobiledgeX  vm_list=${vmlist_update} 

   Should Be Equal  ${update_return['data']['key']['name']}  ${name}
   Should Be Equal  ${update_return['data']['vms']}  ${None}

# ECQ-2394
UpdateVMPool - shall be able to update with 1 VM
   [Documentation]
   ...  - send CreateVMPool with 3 VMs
   ...  - verify pool is created
   ...  - send UpdateVMPool with 1 VM 
   ...  - verify pool list is correct

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.11  internal_ip=2.2.2.1 
   &{vm2}=  Create Dictionary  name=vm2  external_ip=80.187.128.12  internal_ip=2.2.2.2
   &{vm3}=  Create Dictionary  name=vm3  external_ip=80.187.128.13  internal_ip=2.2.2.3
   @{vmlist}=  Create List  ${vm1}  ${vm2}  ${vm3}

   ${pool_return}=  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.11
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1 
   Should Be Equal  ${pool_return['data']['vms'][1]['name']}  vm2
   Should Be Equal  ${pool_return['data']['vms'][1]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${pool_return['data']['vms'][1]['net_info']['internal_ip']}  2.2.2.2
   Should Be Equal  ${pool_return['data']['vms'][2]['name']}  vm3
   Should Be Equal  ${pool_return['data']['vms'][2]['net_info']['external_ip']}  80.187.128.13
   Should Be Equal  ${pool_return['data']['vms'][2]['net_info']['internal_ip']}  2.2.2.3
   Length Should Be   ${pool_return['data']['vms']}  3

   &{vm1}=  Create Dictionary  name=vm11  external_ip=80.187.128.111  internal_ip=2.2.2.11
   @{vmlist_update}=  Create List  ${vm1}

   ${update_return}=  Update VM Pool  region=US  token=${token}  vm_pool_name=${pool_name}  org_name=MobiledgeX  vm_list=${vmlist_update}

   Should Be Equal  ${update_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${update_return['data']['vms'][0]['name']}  vm11
   Should Be Equal  ${update_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.111
   Should Be Equal  ${update_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.11
   Length Should Be   ${update_return['data']['vms']}  1

# ECQ-2395
UpdateVMPool - shall be able to update with 10 VMs 
   [Documentation]
   ...  - send CreateVMPool with no VMs
   ...  - verify pool is created
   ...  - send UpdateVMPool with 10 VMs
   ...  - verify pool list is correct

   ${pool_return}=  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX
   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['vms']}  ${None}

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=2.2.2.1
   &{vm2}=  Create Dictionary  name=vm2  external_ip=80.187.128.12  internal_ip=2.2.2.2
   &{vm3}=  Create Dictionary  name=vm3  external_ip=80.187.128.13  internal_ip=2.2.2.3
   &{vm4}=  Create Dictionary  name=vm4  external_ip=80.187.128.14  internal_ip=2.2.2.4
   &{vm5}=  Create Dictionary  name=vm5  external_ip=80.187.128.15  internal_ip=2.2.2.5
   &{vm6}=  Create Dictionary  name=vm6  external_ip=80.187.128.16  internal_ip=2.2.2.6
   &{vm7}=  Create Dictionary  name=vm7  internal_ip=2.2.2.7
   &{vm8}=  Create Dictionary  name=vm8  external_ip=80.187.128.18  internal_ip=2.2.2.8
   &{vm9}=  Create Dictionary  name=vm9  external_ip=80.187.128.19  internal_ip=2.2.2.9
   &{vm10}=  Create Dictionary  name=vm10  external_ip=80.187.128.10  internal_ip=2.2.2.10
   @{vmlist}=  Create List  ${vm1}  ${vm2}  ${vm3}  ${vm4}  ${vm5}  ${vm6}  ${vm7}  ${vm8}  ${vm9}  ${vm10}

   ${update_return}=  Update VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Be Equal  ${update_return['data']['vms'][0]['name']}  vm1
   Dictionary Should Not Contain Key  ${update_return['data']['vms'][0]['net_info']}  external_ip
   Should Be Equal  ${update_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1
   Should Be Equal  ${update_return['data']['vms'][1]['name']}  vm2
   Should Be Equal  ${update_return['data']['vms'][1]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${update_return['data']['vms'][1]['net_info']['internal_ip']}  2.2.2.2
   Should Be Equal  ${update_return['data']['vms'][2]['name']}  vm3
   Should Be Equal  ${update_return['data']['vms'][2]['net_info']['external_ip']}  80.187.128.13
   Should Be Equal  ${update_return['data']['vms'][2]['net_info']['internal_ip']}  2.2.2.3
   Should Be Equal  ${update_return['data']['vms'][3]['name']}  vm4
   Should Be Equal  ${update_return['data']['vms'][3]['net_info']['external_ip']}  80.187.128.14
   Should Be Equal  ${update_return['data']['vms'][3]['net_info']['internal_ip']}  2.2.2.4
   Should Be Equal  ${update_return['data']['vms'][4]['name']}  vm5
   Should Be Equal  ${update_return['data']['vms'][4]['net_info']['external_ip']}  80.187.128.15
   Should Be Equal  ${update_return['data']['vms'][4]['net_info']['internal_ip']}  2.2.2.5
   Should Be Equal  ${update_return['data']['vms'][5]['name']}  vm6
   Should Be Equal  ${update_return['data']['vms'][5]['net_info']['external_ip']}  80.187.128.16
   Should Be Equal  ${update_return['data']['vms'][5]['net_info']['internal_ip']}  2.2.2.6
   Should Be Equal  ${update_return['data']['vms'][6]['name']}  vm7
   Dictionary Should Not Contain Key  ${update_return['data']['vms'][6]['net_info']}  external_ip
   Should Be Equal  ${update_return['data']['vms'][6]['net_info']['internal_ip']}  2.2.2.7
   Should Be Equal  ${update_return['data']['vms'][7]['name']}  vm8
   Should Be Equal  ${update_return['data']['vms'][7]['net_info']['external_ip']}  80.187.128.18
   Should Be Equal  ${update_return['data']['vms'][7]['net_info']['internal_ip']}  2.2.2.8
   Should Be Equal  ${update_return['data']['vms'][8]['name']}  vm9
   Should Be Equal  ${update_return['data']['vms'][8]['net_info']['external_ip']}  80.187.128.19
   Should Be Equal  ${update_return['data']['vms'][8]['net_info']['internal_ip']}  2.2.2.9
   Should Be Equal  ${update_return['data']['vms'][9]['name']}  vm10
   Should Be Equal  ${update_return['data']['vms'][9]['net_info']['external_ip']}  80.187.128.10
   Should Be Equal  ${update_return['data']['vms'][9]['net_info']['internal_ip']}  2.2.2.10

   Length Should Be   ${update_return['data']['vms']}  10

# ECQ-2394
UpdateVMPool - shall be able to update VM status from free to free
   [Documentation]
   ...  - send CreateVMPool with 3 VMs
   ...  - verify pool is created
   ...  - send UpdateVMPool with 1 VM
   ...  - verify pool list is correct

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.11  internal_ip=2.2.2.1
   &{vm2}=  Create Dictionary  name=vm2  external_ip=80.187.128.12  internal_ip=2.2.2.2
   &{vm3}=  Create Dictionary  name=vm3  external_ip=80.187.128.13  internal_ip=2.2.2.3
   @{vmlist}=  Create List  ${vm1}  ${vm2}  ${vm3}

   ${pool_return}=  Create VM Pool  region=US  token=${token}  org_name=MobiledgeX  vm_list=${vmlist}

   Should Be Equal  ${pool_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${pool_return['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.11
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1
   Should Be Equal  ${pool_return['data']['vms'][1]['name']}  vm2
   Should Be Equal  ${pool_return['data']['vms'][1]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${pool_return['data']['vms'][1]['net_info']['internal_ip']}  2.2.2.2
   Should Be Equal  ${pool_return['data']['vms'][2]['name']}  vm3
   Should Be Equal  ${pool_return['data']['vms'][2]['net_info']['external_ip']}  80.187.128.13
   Should Be Equal  ${pool_return['data']['vms'][2]['net_info']['internal_ip']}  2.2.2.3
   Length Should Be   ${pool_return['data']['vms']}  3

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.11  internal_ip=2.2.2.1  state=VmForceFree
   &{vm2}=  Create Dictionary  name=vm2  external_ip=80.187.128.12  internal_ip=2.2.2.2  state=VmForceFree 
   &{vm3}=  Create Dictionary  name=vm3  external_ip=80.187.128.13  internal_ip=2.2.2.3  state=VmForceFree 
   @{vmlist_update}=  Create List  ${vm1}  ${vm2}  ${vm3}

   ${update_return}=  Update VM Pool  region=US  token=${token}  vm_pool_name=${pool_name}  org_name=MobiledgeX  vm_list=${vmlist_update}

   Should Be Equal  ${update_return['data']['key']['name']}  ${pool_name}
   Should Be Equal  ${update_return['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${update_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.11
   Should Be Equal  ${update_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1
   Should Be True   'state' not in ${update_return['data']['vms'][0]}  
   Should Be Equal  ${update_return['data']['vms'][1]['name']}  vm2
   Should Be Equal  ${update_return['data']['vms'][1]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${update_return['data']['vms'][1]['net_info']['internal_ip']}  2.2.2.2
   Should Be True   'state' not in ${update_return['data']['vms'][1]}
   Should Be Equal  ${update_return['data']['vms'][2]['name']}  vm3
   Should Be Equal  ${update_return['data']['vms'][2]['net_info']['external_ip']}  80.187.128.13
   Should Be Equal  ${update_return['data']['vms'][2]['net_info']['internal_ip']}  2.2.2.3
   Should Be True   'state' not in ${update_return['data']['vms'][2]}
   Length Should Be   ${update_return['data']['vms']}  3

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default VM Pool Name

   Set Suite Variable  ${pool_name}
