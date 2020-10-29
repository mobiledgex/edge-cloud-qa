*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout   32 min 

Test Teardown  Teardown

*** Variables ***
${cloudlet_name_openstack_fairview}  automationFairviewCloudlet
${operator_name_openstack_fairview}  GDDT
${physical_name_openstack_fairview}  fairview
${region}  EU

${test_timeout_crm}  60 min

*** Test Cases ***
# ECQ-2798
StreamCloudlet - shall be able to streamcloudlet for Create/Delete cloudlet
   [Documentation]
   ...  - do CreateCloudlet in a thread
   ...  - do StreamCloudlet and verify the CreateCloudlet output
   ...  - do DeleteCloudlet in a thread
   ...  - do StreamCloudlet and verify the DeleteCloudlet output

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_fairview}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_fairview}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  use_thread=${True}
   Sleep  5s
   ${output}=  Stream Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_fairview}

   ${outputstring}=  Convert To String  ${output}
   Should Contain  ${outputstring}  Sourcing access variables
   Should Contain Any  ${outputstring}  Created Cloudlet successfully  Deleted Cloudlet successfully

   Delete Cloudlet  region=EU  operator_org_name=${operator_name_openstack_fairview}  use_thread=${True}
   Sleep  5s
   ${output2}=  Stream Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_fairview}

   ${outputstring2}=  Convert To String  ${output2}
   Should Contain  ${outputstring2}  Deleting cloudlet 
   Should Contain Any  ${outputstring2}  Deleted Cloudlet successfully

*** Keywords ***
Teardown
   Run Keyword and Ignore Error  Delete Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_fairview}
