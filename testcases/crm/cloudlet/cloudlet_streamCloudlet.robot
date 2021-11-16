*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout   32 min 

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${cloudlet_name_openstack_frankfurt}  automationFrankfurtCloudlet
${operator_name_openstack_frankfurt}  TDG
${physical_name_openstack_frankfurt}  frankfurt
${physical_name_crm}  bonn
${region}  US

${test_timeout_crm}  60 min

*** Test Cases ***
# ECQ-2798
StreamCloudlet - shall be able to streamcloudlet for Create/Delete cloudlet
   [Documentation]
   ...  - do CreateCloudlet in a thread
   ...  - do StreamCloudlet and verify the CreateCloudlet output
   ...  - do DeleteCloudlet in a thread
   ...  - do StreamCloudlet and verify the DeleteCloudlet output

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_crm}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_crm}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=${env_vars}  use_thread=${True}
   Sleep  5s
   ${output}=  Stream Cloudlet  region=${region}  operator_org_name=${operator_name_crm}

   ${outputstring}=  Convert To String  ${output}
   Should Contain  ${outputstring}  Sourcing access variables
   Should Contain Any  ${outputstring}  Created Cloudlet successfully  Deleted Cloudlet successfully

   Delete Cloudlet  region=${region}  operator_org_name=${operator_name_crm}  use_thread=${True}
   Sleep  5s
   ${output2}=  Stream Cloudlet  region=${region}  operator_org_name=${operator_name_crm}

   ${outputstring2}=  Convert To String  ${output2}
   Should Contain  ${outputstring2}  Deleting cloudlet 
   Should Contain Any  ${outputstring2}  Deleted Cloudlet successfully

*** Keywords ***
Setup
   IF  'Bonn' in '${cloudlet_name_crm}'
      ${env_vars}=  Set Variable  FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02
   ELSE
      ${env_vars}=  Set Variable  ${None}
   END

   Set Suite Variable  ${env_vars}

Teardown
   Run Keyword and Ignore Error  Delete Cloudlet  region=${region}  operator_org_name=${operator_name_crm}
