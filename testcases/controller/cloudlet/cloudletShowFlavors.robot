*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections

Test Setup      Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${region}  EU
${cloudlet}=  ${cloudlet_name_crm}
${cloudlet_org}=  ${operator_name_crm}

*** Test Cases ***
# ECQ-3611
ShowFlavorsForCloudlet - shall be able to get all supported flavors for a cloudlet
   [Documentation]
   ...  - Get all flavors in the region 
   ...  - call FindFlavorMatch to see which flavors are supported on a cloudlet
   ...  - call ShowFlavorsForCloudlet
   ...  - verify it returns only the flavors supported from FindFlavorMatch

   @{flavors}=  Show Flavors  region=${region}  token=${token}  use_defaults=${False}

   @{passlist}=  Create List
   @{faillist}=  Create List
   
   FOR  ${f}  IN  @{flavors}
      ${msg}=  Run Keyword and Ignore Error  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=${f['data']['key']['name']} 

      IF  '${msg[0]}' == 'PASS'
          Append To List  ${passlist}  ${f['data']['key']['name']} 
      ELSE
          Append To List  ${faillist}  ${f['data']['key']['name']}
      END
   END

   @{supported}=  Create List
   @{show}=  Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}
   FOR  ${sf}  IN  @{show}
      Append To List  ${supported}  ${sf['data']['name']}
   END

   Sort List  ${passlist}
   Sort List  ${faillist}
   Sort List  ${supported}

   Lists Should Be Equal  ${supported}  ${passlist}

   List Should Contain Value  ${supported}  ${flavor_name_good}
   List Should Contain Value  ${supported}  ${gpu_flavor_name_good}

   IF  ${platform} == 11    # VCD
      Length Should Be  ${faillist}  0  # VCD supports all flavors
      List Should Contain Value   ${supported}  ${gpu_flavor_name_bad}
      List Should Contain Value   ${supported}  ${large_flavor_name_bad}
   ELSE
      List Should Not Contain Value   ${supported}  ${gpu_flavor_name_bad}
      List Should Not Contain Value   ${supported}  ${large_flavor_name_bad}
   END

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${c}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet}  token=${token}  use_defaults=${False}
   ${platform}=  Set Variable  ${c[0]['data']['platform_type']}

   ${flavor_good}=      Create Flavor  region=${region}
   ${gpu_flavor_good}=       Create Flavor  region=${region}  flavor_name=${flavor_good['data']['key']['name']}1  disk=80  optional_resources=gpu=pci:1
   ${gpu_flavor_bad}=  Create Flavor  region=${region}  flavor_name=${flavor_good['data']['key']['name']}2  disk=80  optional_resources=gpu=xgpu:1
   ${large_flavor_bad}=     Create Flavor  region=${region}  flavor_name=${flavor_good['data']['key']['name']}3  disk=8000

   ${flavor_name_good}=       Set Variable  ${flavor_good['data']['key']['name']}
   ${gpu_flavor_name_good}=   Set Variable  ${gpu_flavor_good['data']['key']['name']}
   ${gpu_flavor_name_bad}=    Set Variable  ${gpu_flavor_bad['data']['key']['name']}
   ${large_flavor_name_bad}=    Set Variable  ${large_flavor_bad['data']['key']['name']}

   Set Suite Variable  ${platform}

   Set Suite Variable  ${flavor_name_good}
   Set Suite Variable  ${gpu_flavor_name_good}
   Set Suite Variable  ${gpu_flavor_name_bad}
   Set Suite Variable  ${large_flavor_name_bad}
 
