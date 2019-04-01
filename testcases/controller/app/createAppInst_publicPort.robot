*** Settings ***
Documentation   CreateAppInst 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
AppInst - user shall be able to add 1 TCP port with same public port
    [Documentation]
    ...  create an app with tcp:1
    ...  create an app instance 
    ...  verify internal and public port is 1

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:1
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  -  tcp  .

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1 
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

AppInst - user shall be able to add 1 UDP port with same public port
    [Documentation]
    ...  create an app with udp:1
    ...  create an app instance
    ...  verify internal and public port is 1

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:1
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  -  udp  .

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

AppInst - user shall be able to add 10 UDP port with same public port
    [Documentation]
    ...  create an app with udp:1 thru 10
    ...  create an app instance
    ...  verify internal and public port is 1-10

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:1,udp:2,udp:3,udp:4,udp:5,udp:6,udp:7,udp:8,udp:9,udp:10
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  -  udp  .

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[1].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[2].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[3].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[4].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[5].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[6].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[7].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[8].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[9].FQDN_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  10

AppInst - user shall be able to add 10 TCP port with same public port
    [Documentation]
    ...  create an app with tcp:1 thru 10
    ...  create an app instance
    ...  verify internal and public port is 1-10

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:1,tcp:2,tcp:3,tcp:4,tcp:5,tcp:6,tcp:7,tcp:8,tcp:9,tcp:10
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  -  tcp  .

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[1].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[2].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[3].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[4].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[5].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[6].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[7].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[8].FQDN_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[9].FQDN_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  10

AppInst - user shall be able to add TCP and UDP ports with the same port numbers
    [Documentation]
    ...  create an app with tcp and udp with the same port numbes
    ...  create an app instance
    ...  verify tcp and udp can use the same public port

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:1,udp:1,tcp:3,udp:3,tcp:5,udp:5,tcp:7,udp:7,tcp:9,udp:9
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${fqdn_prefix_tcp}=  Catenate  SEPARATOR=  ${app_default}  -  tcp  .
    ${fqdn_prefix_udp}=  Catenate  SEPARATOR=  ${app_default}  -  udp  .

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[0].FQDN_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[1].FQDN_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[2].FQDN_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[3].FQDN_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[4].FQDN_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[5].FQDN_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[6].FQDN_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[7].FQDN_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          1  #LProtoTCP
    Should Be Equal              ${appInst.mapped_ports[8].FQDN_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          2  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[9].FQDN_prefix}    ${fqdn_prefix_udp}

    Length Should Be   ${appInst.mapped_ports}  10

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor   
    Create Cluster  
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Log To Console  Done Creating Cluster Instance
