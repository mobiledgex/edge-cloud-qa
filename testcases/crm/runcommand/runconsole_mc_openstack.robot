*** Settings ***
Documentation  RunConsole on openstack VM 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  RequestsLibrary

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_vm}  automationBonnCloudlet
${operator_name_openstack}  TDG
${developer_artifactory}  artifactory

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
	
${test_timeout_crm}  15 min

${region}=  US

*** Test Cases ***
# ECQ-2074
RunConsole - console URL shall be returned on openstack
   [Documentation]
   ...  - deploy VM app instance 
   ...  - verify RunConsole works and console url returns 200

   Create App  region=${region}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015  #developer_name=${developer_artifactory}  #default_flavor_name=${cluster_flavor_name}
   ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=dummycluster  #developer_name=${developer_artifactory}  cluster_instance_developer_name=${developer_artifactory}

   ${console}=  Run Console  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=dummycluster
   log to console  ${console} ${console['console']['url']}

   Create Session  console  ${console['console']['url']} 
   ${resp}=  Get Request  console  /                    #${console['console']['url']}
   Should Be Equal As Strings  ${resp.status_code}  200

*** Keywords ***
Setup
    Create Flavor  region=${region}  disk=80

