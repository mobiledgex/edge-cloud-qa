*** Settings ***
Documentation   CreateAppInst VM port range 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	

Library         String
	
Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

*** Test Cases ***
AppInst - user shall be able to add with TCP/UDP port range for VM 
    [Documentation]
    ...  create a vm app with tcp:1-10 udp:1-10
    ...  create an app instance
    ...  verify ports are correct

    Create App  access_ports=tcp:1-10,udp:1-10  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${public_path}=  Set Variable  ${app_default}-udp.

    Should Be Equal              ${appInst.uri}    ${developer_name_default}${app_default}${version_default}.${cloudlet_name}.${operator_name}.mobiledgex.net

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].end_port}       10
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[1].end_port}       10
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP

    Length Should Be   ${appInst.mapped_ports}  2

*** Keywords ***
Setup
    Create Developer
    Create Flavor

    ${cluster_instance_default}=  Get Default Cluster Name
    ${developer_name_default}=    Get Default Developer Name
    ${version_default}=           Get Default App Version
    ${version_default}=           Remove String  ${version_default}  .

    Set Suite Variable  ${cluster_instance_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${version_default}
