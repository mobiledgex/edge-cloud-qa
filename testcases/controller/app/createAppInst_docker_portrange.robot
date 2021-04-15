*** Settings ***
Documentation   CreateAppInst port range docker

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	

Library         String
	
Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
AppInst - user shall be able to add with TCP port range for docker 
    [Documentation]
    ...  create a docker app with tcp:1-10
    ...  create an app instance
    ...  verify ports are correct
	
    Create App  access_ports=tcp:1-10  deployment=docker
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name

    Should Be Equal              ${appInst.uri}    ${cluster_instance_default}.${cloudlet_name}.${operator_name}.mobiledgex.net

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1 
    Should Be Equal As Integers  ${appInst.mapped_ports[0].end_port}       10
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP

    Length Should Be   ${appInst.mapped_ports}  1

AppInst - user shall be able to add with UDP port range for docker
    [Documentation]
    ...  create a docker app with udp:1-10
    ...  create an app instance
    ...  verify ports are correct

    Create App  access_ports=udp:1-10  deployment=docker
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name

    Should Be Equal              ${appInst.uri}    ${cluster_instance_default}.${cloudlet_name}.${operator_name}.mobiledgex.net

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].end_port}       10
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP

    Length Should Be   ${appInst.mapped_ports}  1

AppInst - user shall be able to add with TCP/UDP port range for docker
    [Documentation]
    ...  create a docker app with tcp:1-10 udp:1-10
    ...  create an app instance
    ...  verify ports are correct

    Create App  access_ports=tcp:100-160,udp:100-160  deployment=docker
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name

    Should Be Equal              ${appInst.uri}    ${cluster_instance_default}.${cloudlet_name}.${operator_name}.mobiledgex.net

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  100
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    100
    Should Be Equal As Integers  ${appInst.mapped_ports[0].end_port}       160
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  100
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    100
    Should Be Equal As Integers  ${appInst.mapped_ports[1].end_port}       160
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP

    Length Should Be   ${appInst.mapped_ports}  2

# direct not supported
# ECQ-2107
#AppInst - user shall be able to add with TCP/UDP port range for docker access_type=direct
#    [Documentation]
#    ...  create a docker direct app with tcp:1-101 udp:1-101
#    ...  create an app instance
#    ...  verify ports are correct
#
#    Create App  access_ports=tcp:100-201,udp:1-100  deployment=docker  access_type=direct
#    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
#
#    ${app_default}=  Get Default App Name
#
#    Should Be Equal              ${appInst.uri}    ${cluster_instance_default}.${cloudlet_name}.${operator_name}.mobiledgex.net
#
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  100
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    100
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].end_port}       201
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
#
#    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  1
#    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    1
#    Should Be Equal As Integers  ${appInst.mapped_ports[1].end_port}       100
#    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP
#
#    Length Should Be   ${appInst.mapped_ports}  2

*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    #Create Cluster  
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  ip_access=IpAccessDedicated  deployment=docker
    Log To Console  Done Creating Cluster Instance

    ${cluster_instance_default}=  Get Default Cluster Name
    ${developer_name_default}=    Get Default Developer Name
    ${version_default}=           Get Default App Version
    ${version_default}=           Remove String  ${version_default}  .

    Set Suite Variable  ${cluster_instance_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${version_default}
