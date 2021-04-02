*** Settings ***
Documentation  AddVMPoolMember

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections
     
Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-2339
AddVMPoolMember - shall be able to add member to empty list
   [Documentation]
   ...  - send CreateVMPool with empty list
   ...  - add 1 member 
   ...  - verify member is added 
   ...  - delete member
   ...  - verify member is delete

   ${name}=  Generate Random String  length=100

   ${pool_return}=  Create VM Pool  region=US  token=${token}  vm_pool_name=${name}  org_name=packet  use_defaults=False

   Should Be Equal   ${pool_return['data']['key']['name']}  ${name} 
   Should Be Equal   ${pool_return['data']['vms']}  ${None} 

   Add VM Pool Member  region=US  token=${token}  vm_pool_name=${name}  org_name=packet  vm_name=x1  external_ip=80.187.128.12  internal_ip=2.2.2.2

   ${pool}=  Show VM Pool  region=US  token=${token}  vm_pool_name=${name}  org_name=packet
   Should Be Equal   ${pool[0]['data']['key']['name']}  ${name}
   Length Should Be  ${pool[0]['data']['vms']}  1

   Remove VM Pool Member  region=US  token=${token}  vm_pool_name=${name}  org_name=packet  vm_name=x1

   ${pool}=  Show VM Pool  region=US  token=${token}  vm_pool_name=${name}  org_name=packet
   Should Be Equal   ${pool[0]['data']['key']['name']}  ${name}
   Should Be Equal   ${pool_return['data']['vms']}  ${None}

# ECQ-2340
AddVMPoolMember - shall be able to add 10 members 
   [Documentation]
   ...  - send CreateVMPool with 1 VM
   ...  - add 9 members
   ...  - verify members is added
   ...  - delete members
   ...  - verify members are deleted

   &{vm1}=  Create Dictionary  name=vm1  external_ip=80.187.128.11  internal_ip=2.2.2.1
   @{vmlist}=  Create List  ${vm1}
   Create VM Pool  region=US  token=${token}  org_name=packet  vm_list=${vmlist}

   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm2  external_ip=80.187.128.12  internal_ip=2.2.2.2
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm3  external_ip=80.187.128.13  internal_ip=2.2.2.3
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm4  external_ip=80.187.128.14  internal_ip=2.2.2.4
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm5                             internal_ip=2.2.2.5
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm6  external_ip=80.187.128.16  internal_ip=2.2.2.6
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm7  external_ip=80.187.128.17  internal_ip=2.2.2.7
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm8  external_ip=80.187.128.18  internal_ip=2.2.2.8
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm9  external_ip=80.187.128.19  internal_ip=2.2.2.9
   Add VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm10                            internal_ip=2.2.2.10

   ${pool_return}=  Show VM Pool  region=US  token=${token}  org_name=packet

   Should Be Equal  ${pool_return[0]['data']['vms'][0]['name']}  vm1
   Should Be Equal  ${pool_return[0]['data']['vms'][0]['net_info']['external_ip']}  80.187.128.11
   Should Be Equal  ${pool_return[0]['data']['vms'][0]['net_info']['internal_ip']}  2.2.2.1
   Should Be Equal  ${pool_return[0]['data']['vms'][1]['name']}  vm2
   Should Be Equal  ${pool_return[0]['data']['vms'][1]['net_info']['external_ip']}  80.187.128.12
   Should Be Equal  ${pool_return[0]['data']['vms'][1]['net_info']['internal_ip']}  2.2.2.2
   Should Be Equal  ${pool_return[0]['data']['vms'][2]['name']}  vm3
   Should Be Equal  ${pool_return[0]['data']['vms'][2]['net_info']['external_ip']}  80.187.128.13
   Should Be Equal  ${pool_return[0]['data']['vms'][2]['net_info']['internal_ip']}  2.2.2.3
   Should Be Equal  ${pool_return[0]['data']['vms'][3]['name']}  vm4
   Should Be Equal  ${pool_return[0]['data']['vms'][3]['net_info']['external_ip']}  80.187.128.14
   Should Be Equal  ${pool_return[0]['data']['vms'][3]['net_info']['internal_ip']}  2.2.2.4
   Should Be Equal  ${pool_return[0]['data']['vms'][4]['name']}  vm5
   Dictionary Should Not Contain Key  ${pool_return[0]['data']['vms'][4]['net_info']}  external_ip
   Should Be Equal  ${pool_return[0]['data']['vms'][4]['net_info']['internal_ip']}  2.2.2.5
   Should Be Equal  ${pool_return[0]['data']['vms'][5]['name']}  vm6
   Should Be Equal  ${pool_return[0]['data']['vms'][5]['net_info']['external_ip']}  80.187.128.16
   Should Be Equal  ${pool_return[0]['data']['vms'][5]['net_info']['internal_ip']}  2.2.2.6
   Should Be Equal  ${pool_return[0]['data']['vms'][6]['name']}  vm7
   Should Be Equal  ${pool_return[0]['data']['vms'][6]['net_info']['external_ip']}  80.187.128.17
   Should Be Equal  ${pool_return[0]['data']['vms'][6]['net_info']['internal_ip']}  2.2.2.7
   Should Be Equal  ${pool_return[0]['data']['vms'][7]['name']}  vm8
   Should Be Equal  ${pool_return[0]['data']['vms'][7]['net_info']['external_ip']}  80.187.128.18
   Should Be Equal  ${pool_return[0]['data']['vms'][7]['net_info']['internal_ip']}  2.2.2.8
   Should Be Equal  ${pool_return[0]['data']['vms'][8]['name']}  vm9
   Should Be Equal  ${pool_return[0]['data']['vms'][8]['net_info']['external_ip']}  80.187.128.19
   Should Be Equal  ${pool_return[0]['data']['vms'][8]['net_info']['internal_ip']}  2.2.2.9
   Should Be Equal  ${pool_return[0]['data']['vms'][9]['name']}  vm10
   Dictionary Should Not Contain Key  ${pool_return[0]['data']['vms'][9]['net_info']}  external_ip
   Should Be Equal  ${pool_return[0]['data']['vms'][9]['net_info']['internal_ip']}  2.2.2.10
   Length Should Be   ${pool_return[0]['data']['vms']}  10

   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm6  

   ${pool_return2}=  Show VM Pool  region=US  token=${token}  org_name=packet
   Should Be Equal  ${pool_return2[0]['data']['vms'][5]['name']}  vm7
   Should Be Equal  ${pool_return2[0]['data']['vms'][5]['net_info']['external_ip']}  80.187.128.17
   Should Be Equal  ${pool_return2[0]['data']['vms'][5]['net_info']['internal_ip']}  2.2.2.7
   Length Should Be   ${pool_return2[0]['data']['vms']}  9 
   
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm1
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm2
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm3  
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm4 
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm5
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm7
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm8
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm9
   Remove VM Pool Member  region=US  token=${token}  org_name=packet  vm_name=vm10

   ${pool_return3}=  Show VM Pool  region=US  token=${token}  org_name=packet
   Should Be Equal  ${pool_return3[0]['data']['vms']}  ${None}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
