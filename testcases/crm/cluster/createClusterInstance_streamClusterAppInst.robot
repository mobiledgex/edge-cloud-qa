*** Settings ***
Documentation   StreamClusterInst/StreamAppInst 

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Timeout     ${test_timeout_crm}

Test Setup      Setup
Test Teardown   Teardown
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationHamburgCloudlet   #has to match crm process startup parms
${operator_name_openstack}  TDG

${docker_image}  docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:8.0

${test_timeout_crm}  15 min

${region}=  EU

*** Test Cases ***
# ECQ-2799
StreamClusterInst/StreamAppInst - shall be to do StreamClusterInst and StreamAppInst
   [Documentation]
   ...  - Create a cluster instance in a thread
   ...  - do StreamClusterInst and verify the output
   ...  - do CreateApp and CreateAppInst in a thread
   ...  - do StreamAppInst and verify the output
   ...  - do DeleteAppInst in a thread
   ...  - do StreamAppInst and verify the output
   ...  - do DeleteClusterInst in a thread
   ...  - do StreamClusterInst and verify the output

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker  use_thread=${True}
   Sleep  5 s
   ${output}=  Stream Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   ${outputstring}=  Convert To String  ${output}
   Should Contain  ${outputstring}  Creating
   Should Contain  ${outputstring}  Created ClusterInst successfully

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2000  image_type=ImageTypeDocker  access_type=loadbalancer  deployment=docker
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  use_thread=${True}
   Sleep  5 s
   ${output_app}=  Stream App Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   ${outputstring_app}=  Convert To String  ${output_app}
   Should Contain  ${outputstring_app}  Creating
   Should Contain  ${outputstring_app}  Created AppInst successfully

   Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  use_thread=${True}
   Sleep  5 s
   ${output_app2}=  Stream App Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   ${outputstring_app2}=  Convert To String  ${output_app2}
   Should Contain  ${outputstring_app2}  Deleting
   Should Contain  ${outputstring_app2}  Deleted AppInst successfully

   Delete Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  use_thread=${True}
   Sleep  5 s
   ${output2}=  Stream Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}

   ${outputstring2}=  Convert To String  ${output2}
   Should Contain  ${outputstring2}  Deleting
   Should Contain  ${outputstring2}  Deleted ClusterInst successfully

*** Keywords ***
Setup
    ${time}=  Get Time  epoch
    Create Flavor  region=${region}  flavor_name=flavor${time}

Teardown
   Run Keyword and Ignore Error  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}
   Run Keyword and Ignore Error  Delete App  region=${region}
   Run Keyword and Ignore Error  Delete Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}
   Run Keyword and Ignore Error  Delete Flavor  region=${region}
