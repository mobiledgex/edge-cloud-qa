*** Settings ***
Documentation  VM deployment 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}    #WITH NAME  mc1

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}  US

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
	
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-4443
User shall be able to create multiple VM/LB deployment on CRM
    [Documentation]
    ...  - deploy 2 VM apps at the same time
    ...  - verify both apps get deployed and the 2nd waits on the download from the 1st

    Create App  app_name=${app_name_default}1  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085   access_type=loadbalancer    region=${region} 
    Create App  app_name=${app_name_default}2  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085   access_type=loadbalancer    region=${region}

    ${app_inst1}=  Create App Instance  app_name=${app_name_default}1  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=dummycluster  region=${region}  use_thread=${True}
    ${app_inst2}=  Create App Instance  app_name=${app_name_default}2  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=dummycluster  region=${region}  use_thread=${True}

    Wait For Replies  ${app_inst1}  ${app_inst2}

    ${app_inst_stream_output}=  Get Create App Instance Output

    ${create_count}=  Get Count  ${app_inst_stream_output}  Creating VM Image from URL:
    ${wait_count}=    Get Count  ${app_inst_stream_output}  Waiting for download of
    Should Be Equal As Numbers  ${create_count}  1
    Should Be Equal As Numbers  ${wait_count}    1
 
*** Keywords ***
Setup
   Create Flavor  disk=80  region=${region}

   ${app_name_default}=  Get Default App Name
   Set Suite Variable  ${app_name_default}
