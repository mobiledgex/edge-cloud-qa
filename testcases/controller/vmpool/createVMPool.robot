*** Settings ***
Documentation  CreateVMPool

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  packet
${region}=  US

*** Test Cases ***
# ECQ-2319
CreateVMPool - shall be able to create without VM list 
   [Documentation]
   ...  - send CreateVMPool with long pool name 
   ...  - verify pool is created 

   ${name}=  Generate Random String  length=100

   ${pool_return}=  Create VM Pool  region=${region}  token=${token}  vm_pool_name=${name}  org_name=${organization}  use_defaults=False

   Should Be Equal  ${pool_return['data']['key']['name']}  ${name} 

# ECQ-2320
CreateVMPool - shall be able to create with numbers in pool name 
   [Documentation]
   ...  - send CreateVMPool with numbers in pool name
   ...  - verify pool is created 

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   
   ${pool_return}=  Create VM Pool  region=${region}  token=${token}  vm_pool_name=${epoch}  org_name=${organization}  use_defaults=False

   Should Be Equal  ${pool_return['data']['key']['name']}  ${epoch} 

# ECQ-2321
CreateVMPool - shall be able to create with 1 VM
   [Documentation]
   ...  - send CreateVMPool with 1 VM 
   ...  - verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.12  internal_ip=2.2.2.2 
   @{vmlist}=  Create List  ${vm1}

   ${pool_return}=  Create VM Pool  region=${region}  token=${token}  org_name=${organization}  vm_list=${vmlist}

   Should Be Equal  ${pool_return['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.2 

   Length Should Be   ${pool_return['data']['vms']}  1

# ECQ-2322
CreateVMPool - shall be able to create with internal address only 
   [Documentation]
   ...  - send CreateVMPool with internal address only 
   ...  - verify pool is created

   &{vm1}=  Create Dictionary  name=vm1  internal_ip=2.2.2.2
   @{vmlist}=  Create List  ${vm1}

   ${pool_return}=  Create VM Pool  region=${region}  token=${token}  org_name=${organization}  vm_list=${vmlist}

   Should Be Equal  ${pool_return['data']['vms'][0]['name']}  vm1
   Dictionary Should Not Contain Key  ${pool_return['data']['vms'][0]['net_info']}  external_ip
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.2

   Length Should Be   ${pool_return['data']['vms']}  1

# ECQ-2323
CreateVMPool - shall be able to create with 10 VMs 
   [Documentation]
   ...  - send CreateVMPool with 10 VMs
   ...  - verify all pools are created

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.12  internal_ip=2.2.2.1
   &{vm2}=  Create Dictionary  name=vm2  external_ip=80.187.128.13  internal_ip=2.2.2.2
   &{vm3}=  Create Dictionary  name=vm3  external_ip=80.187.128.14  internal_ip=2.2.2.3
   &{vm4}=  Create Dictionary  name=vm4  external_ip=80.187.128.15  internal_ip=2.2.2.4
   &{vm5}=  Create Dictionary  name=vm5  external_ip=80.187.128.16  internal_ip=2.2.2.5
   &{vm6}=  Create Dictionary  name=vm6  external_ip=80.187.128.17  internal_ip=2.2.2.6
   &{vm7}=  Create Dictionary  name=vm7  external_ip=80.187.128.18  internal_ip=2.2.2.7
   &{vm8}=  Create Dictionary  name=vm8  external_ip=80.187.128.19  internal_ip=2.2.2.8
   &{vm9}=  Create Dictionary  name=vm9  external_ip=80.187.128.20  internal_ip=2.2.2.9
   &{vm10}=  Create Dictionary  name=vm10  external_ip=80.187.128.21  internal_ip=2.2.2.10
   @{vmlist}=  Create List  ${vm1}  ${vm2}  ${vm3}  ${vm4}  ${vm5}  ${vm6}  ${vm7}  ${vm8}  ${vm9}  ${vm10}

   ${pool_return}=  Create VM Pool  region=${region}  token=${token}  org_name=${organization}  vm_list=${vmlist}

   Should Be Equal  ${pool_return['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${pool_return['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1
   Should Be Equal  ${pool_return['data']['vms'][1]['name']}  vm2
   Should Be Equal  ${pool_return['data']['vms'][1]['net_info']['external_ip']}  80.187.128.13
   Should Be Equal  ${pool_return['data']['vms'][1]['net_info']['internal_ip']}  2.2.2.2
   Should Be Equal  ${pool_return['data']['vms'][2]['name']}  vm3
   Should Be Equal  ${pool_return['data']['vms'][2]['net_info']['external_ip']}  80.187.128.14
   Should Be Equal  ${pool_return['data']['vms'][2]['net_info']['internal_ip']}  2.2.2.3
   Should Be Equal  ${pool_return['data']['vms'][3]['name']}  vm4
   Should Be Equal  ${pool_return['data']['vms'][3]['net_info']['external_ip']}  80.187.128.15
   Should Be Equal  ${pool_return['data']['vms'][3]['net_info']['internal_ip']}  2.2.2.4
   Should Be Equal  ${pool_return['data']['vms'][4]['name']}  vm5
   Should Be Equal  ${pool_return['data']['vms'][4]['net_info']['external_ip']}  80.187.128.16
   Should Be Equal  ${pool_return['data']['vms'][4]['net_info']['internal_ip']}  2.2.2.5
   Should Be Equal  ${pool_return['data']['vms'][5]['name']}  vm6
   Should Be Equal  ${pool_return['data']['vms'][5]['net_info']['external_ip']}  80.187.128.17
   Should Be Equal  ${pool_return['data']['vms'][5]['net_info']['internal_ip']}  2.2.2.6
   Should Be Equal  ${pool_return['data']['vms'][6]['name']}  vm7
   Should Be Equal  ${pool_return['data']['vms'][6]['net_info']['external_ip']}  80.187.128.18
   Should Be Equal  ${pool_return['data']['vms'][6]['net_info']['internal_ip']}  2.2.2.7
   Should Be Equal  ${pool_return['data']['vms'][7]['name']}  vm8
   Should Be Equal  ${pool_return['data']['vms'][7]['net_info']['external_ip']}  80.187.128.19
   Should Be Equal  ${pool_return['data']['vms'][7]['net_info']['internal_ip']}  2.2.2.8
   Should Be Equal  ${pool_return['data']['vms'][8]['name']}  vm9
   Should Be Equal  ${pool_return['data']['vms'][8]['net_info']['external_ip']}  80.187.128.20
   Should Be Equal  ${pool_return['data']['vms'][8]['net_info']['internal_ip']}  2.2.2.9
   Should Be Equal  ${pool_return['data']['vms'][9]['name']}  vm10
   Should Be Equal  ${pool_return['data']['vms'][9]['net_info']['external_ip']}  80.187.128.21
   Should Be Equal  ${pool_return['data']['vms'][9]['net_info']['internal_ip']}  2.2.2.10

   Length Should Be   ${pool_return['data']['vms']}  10

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
