*** Settings ***
Documentation  GPU allocation fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_gpu}  automationParadiseCloudlet
${operator_name_openstack}  GDDT 
${region}  US
${mobiledgex_domain}  mobiledgex.net
${gpu_resource_name}  mygpuresrouce
 
${openstack_flavor_name}  m4.large-gpu
 
${qcow_centos_image}   https://artifactory-qa.mobiledgex.net/artifactory/repo-ldevorg/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d 

${test_timeout_crm}  15 min

*** Test Cases ***
GPU - CreateClusterInst shall fail if gpu=0
   [Documentation]
   ...  create a cluster on openstack with 0 GPU
   ...  verify error is received 

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Create Flavor  region=${region}  flavor_name=${flavor_name}  disk=80  optional_resources=gpu=pci:0

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker

   Should be equal  ${error}  ('code=400', 'error={"message":"No suitable platform flavor found for ${flavor_name}, please try a smaller flavor"}')   
   #Should Contain  ${error}  responseCode = 400
   #Should Contain  ${error}   "message":"no suitable platform flavor found for ${flavor_name}, please try a smaller flavor"

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_gpu}

    Set Suite Variable  ${cloudlet_lowercase}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_gpu}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  mapping=gpu=${gpu_resource_name}
    Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack}  tags=pci=t4gpu:1

    Set Suite Variable  ${rootlb}
