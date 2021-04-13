*** Settings ***
Documentation  flavor create mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-3133
CreateFlavor - mcctl shall be able to create/delete flavor
   [Documentation]
   ...  - send CreateFlavor/DeleteFlavor via mcctl with various parms
   ...  - verify flavor is created/deleted

   [Template]  Success Create/Delete Flavor Via mcctl
      name=${flavor_name}  vcpus=1  disk=1  ram=1
      name=${flavor_name}  vcpus=1  disk=1  ram=1  optresmap=gpu=vgpu:nvidia-63:1
      name=${flavor_name}  vcpus=1  disk=1  ram=1  optresmap=gpu=gpu:nvidia-63:1
      name=${flavor_name}  vcpus=1  disk=1  ram=1  optresmap=gpu=pci:nvidia-63:1
      name=${flavor_name}  vcpus=1  disk=1  ram=1  optresmap=gpu=vgpu:1
      name=${flavor_name}  vcpus=1  disk=1  ram=1  optresmap=gpu=gpu:1
      name=${flavor_name}  vcpus=1  disk=1  ram=1  optresmap=gpu=pci:1
      name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=pu:nvidia-63:1
      name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=VGPU:1
      name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=VGPU:NVIDIA:1


# ECQ-3134
CreateFlavor - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateFlavr via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Create Flavor Via mcctl
      # invalid values
      Error: missing required args: 
      Error: missing required args:  name=${flavor_name}  
      Error: missing required args:  name=${flavor_name}  vcpus=1
      Error: missing required args:  name=${flavor_name}  disk=1
      Error: missing required args:  name=${flavor_name}  ram=1
      Error: missing required args:  name=${flavor_name}  vcpus=1  ram=1
      Error: missing required args:  name=${flavor_name}  disk=1  ram=1
      Error: missing required args:  name=${flavor_name}  disk=1  vcpus=1

      Error: Bad Request (400), Only GPU resources currently supported, use optresmap\=gpu\=$resource:[$specifier:]$count           name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gp=vgpu:nvidia-63:1
      Error: Bad Request (400), Only GPU resources currently supported, use optresmap\=gpu\=$resource:[$specifier:]$count           name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=nas=vgpu:nvidia-63:1
      Error: Bad Request (400), Only GPU resources currently supported, use optresmap\=gpu\=$resource:[$specifier:]$count           name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=nic=vgpu:nvidia-63:1
      Bad Request (400), Non-numeric resource count encountered, found nvidia-63                                       name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=vgpu:nvidia-63
      Bad Request (400), Non-numeric resource count encountered, found nvidia-63                                       name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=vgpu:nvidia-63:x
      Error: Bad Request (400), Missing manditory resource count, ex: optresmap\=gpu\=gpu:1                            name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=vgpu
      Error: Bad Request (400), Invalid optresmap syntax encountered: ex: optresmap\=gpu\=gpu:1                          name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=gpu:::1
#      Error: Bad Request (400), GPU resource type selector must be one of [gpu, pci, vgpu] found pu                    name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=gpu=pu:nvidia-63:1    now succeeds and moved to test above
      Error: value "x" of arg "optresmap\=x" must be formatted as key\=value                                           name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=x
      Error: Bad Request (400), Only GPU resources currently supported, use optresmap\=gpu\=$resource:[$specifier:]$count found x   name=${flavor_name}  disk=1  vcpus=1  ram=1  optresmap=x=x

*** Keywords ***
Setup
   ${flavor_name}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name}

Success Create/Delete Flavor Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   Run mcctl  flavor create region=${region} ${parmss}  version=${version}
   ${show}=  Run mcctl  flavor show region=${region} ${parmss_modify}  version=${version}

   Run mcctl  flavor delete region=${region} ${parmss}  version=${version}

   Should Be Equal  ${show[0]['key']['name']}  ${parms['name']}
   Should Be Equal As Numbers  ${show[0]['ram']}          ${parms['ram']}
   Should Be Equal As Numbers  ${show[0]['vcpus']}        ${parms['vcpus']}
   Should Be Equal As Numbers  ${show[0]['disk']}         ${parms['disk']}

   @{optres}=  Run Keyword If  'optresmap' in ${parms}  Split String  ${parms['optresmap']}  =

   Run Keyword If  'optresmap' in ${parms}  Should Be Equal  ${show[0]['opt_res_map']['${optres[0]}']}  ${optres[1]}
   

Fail Create Flavor Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  flavor create region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
