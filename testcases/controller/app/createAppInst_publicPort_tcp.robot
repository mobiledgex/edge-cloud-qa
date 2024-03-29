*** Settings ***
Documentation   CreateAppInst public port TCP

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  String
Library  DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1
${cloudlet_name_2}  tmocloud-2
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
# ECQ-1219
AppInst - user shall be able to add 1 TCP port with same public port
    [Documentation]
    ...  create an app with tcp:1
    ...  create an app instance 
    ...  verify internal and public port is 1

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:1
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1 
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1220
AppInst - user shall be able to add 10 TCP port with same public port
    [Documentation]
    ...  create an app with tcp:1 thru 10
    ...  create an app instance
    ...  verify internal and public port is 1-10

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:1,tcp:2,tcp:3,tcp:4,tcp:5,tcp:6,tcp:7,tcp:8,tcp:9,tcp:10
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[1].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[2].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[3].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[4].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[5].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[6].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[7].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[8].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[9].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  10

    Run Keyword Unless  (${epoch_time}-90) < ${appInst.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1221
AppInst - user shall be able to add TCP and UDP ports with the same port numbers
    [Documentation]
    ...  create an app with tcp and udp with the same port numbes
    ...  create an app instance
    ...  verify tcp and udp can use the same public port

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:1,udp:1,tcp:3,udp:3,tcp:5,udp:5,tcp:7,udp:7,tcp:9,udp:9
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix_tcp}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -
    #${fqdn_prefix_udp}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[1].fqdn_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[2].fqdn_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[3].fqdn_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[4].fqdn_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[5].fqdn_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[6].fqdn_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[7].fqdn_prefix}    ${fqdn_prefix_udp}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[8].fqdn_prefix}    ${fqdn_prefix_tcp}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[9].fqdn_prefix}    ${fqdn_prefix_udp}

    Length Should Be   ${appInst.mapped_ports}  10

    Run Keyword Unless  (${epoch_time}-90) < ${appInst.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1222
AppInst - 2 appInst on different app and same cluster and same cloudlet shall not be able to allocate the same public TCP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app2 and appInst2 on cluster1 cloudlet1 with tcp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  tcp  -

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=tcp:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1223
AppInst - 2 appInst on different app and different cluster and same cloudlet shall not be able to allocate the same public TCP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with tcp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  tcp  -

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=tcp:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1224
AppInst - 2 appInst on different app/cluster/cloudlet shall be able to allocate the same public TCP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet2 with tcp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 1

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  tcp  -

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=tcp:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1225
AppInst - 2 appInst on same app and different cluster and same cloudlet shall not be able to allocate the same public TCP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app1 and appInst2 on cluster1 cloudlet1 with tcp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    # EDGECLOUD-414 trying to create 2 appinst on different cluster but same cloudlet
	
    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  tcp  -

    # create app2 and appInst on the same port
    #Create App  app_name=${app_default_2}  access_ports=tcp:1
    ${cluster_name_2}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_name_2}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    #Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Match Regexp   '${appInst_2.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1226
AppInst - 2 appInst on same app and different cluster and different cloudlet shall not be able to allocate the same public TCP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app1 and appInst2 on cluster2 cloudlet2 with tcp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    # create app2 and appInst on the same port
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1227
AppInst - User shall be able to add app/appInst, delete, and readd with same public TCP port
    [Documentation]
    ...  create an app1 and appInst1 
    ...  delete the appInst
    ...  readd the appInst
    ...  verify it gets the same public port

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}  no_auto_delete=${True}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    Delete App Instance

    # create appInst again
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1228
AppInst - User shall be able to add app, udpate app, add /appInst with same public TCP port
    [Documentation]
    ...  create an app1 with tcp:1
    ...  update app with tcp:2
    ...  add the appInst
    ...  verify it gets the same public port

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and update app
    Create App  access_ports=tcp:1,tcp:2
    Update App  access_ports=tcp:3,tcp:4

    # create appInst
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  3
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    3
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].internal_port}  4
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].public_port}    4
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[1].fqdn_prefix}    ${fqdn_prefix_1}

    Length Should Be   ${appInst_1.mapped_ports}  2

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1229
AppInst - 3 appInst on different app and different cluster and different cloudlet shall not be able to allocate public TCP port 10000
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with tcp:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with tcp:10000
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000
    ...  verify app3 internal port is 10000 and public port is 10001

    ${epoch_time}=  Get Time  epoch

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    # create appInst2 on the same port
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_name_2}  ${version}  -  tcp  -
    ${autocluster_2}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}  2
    Create App  app_name=${app_name_2}  access_ports=tcp:1
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${autocluster_2}


    # create appInst4 on the port 10000
    ${app_name_3}=  Catenate  SEPARATOR=-  ${app_default_1}  3
    #${fqdn_prefix_3}=  Catenate  SEPARATOR=  ${app_name_3}  ${version}  -  tcp  -
    ${autocluster_3}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}  3
    Create App  app_name=${app_name_3}  access_ports=tcp:10000
    ${appInst_3}=  Create App Instance  app_name=${app_name_3}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${autocluster_3}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    #Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Match Regexp   '${appInst_2.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    # verify app2 uses port 10001
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].internal_port}  10000
    #Should Be Equal As Integers  ${appInst_3.mapped_ports[0].public_port}    10001
    Should Match Regexp   '${appInst_3.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_3.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_3}
    Length Should Be   ${appInst_3.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_3.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_3.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1230
AppInst - appInst shall not allocate TCP port 10000 if already allocated
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with tcp:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with tcp:10000
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000
    ...  verify app3 internal port is 10000 and public port is 10001

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=tcp:10000
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    # create appInst2 on the same port
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_name_2}  ${version}  -  tcp  -
    Create App  app_name=${app_name_2}  access_ports=tcp:10000
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster


    # verify app1 uses port 10000
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  10000
    #Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    10000
    Should Match Regexp   '${appInst_1.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10001
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  10000
    #Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10001
    Should Match Regexp   '${appInst_2.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1231
AppInst - user shall be to add multiple TCP public ports
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with tcp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with tcp:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with tcp:10000
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000
    ...  verify app3 internal port is 10000 and public port is 10001

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    ${app_default}=  Get Default App Name

    Create App  access_ports=tcp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0

    FOR  ${index}  IN RANGE  0  100
       ${epoch_time_multi}=  Get Time  epoch
       ${app_name}=  Catenate  SEPARATOR=-  ${app_default}  ${index}
       Create App  app_name=${app_name}  access_ports=tcp:1
       ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

       
       #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_name}  ${version}  -  tcp  -
       ${public_port}=  Evaluate  10000 + ${index}
       # verify app1 uses port 1
       Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
       Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    ${public_port}
       Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
       #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
       Length Should Be   ${appInst_1.mapped_ports}  1
       Run Keyword Unless  (${epoch_time_multi}-90) < ${appInst_1.created_at.seconds} < (${epoch_time_multi}+90)  Fail  # verify created_at is within 1 minute
       Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    END

# ECQ-1232
#AppInst - user shall not be able to allocate public port tcp:22
#    [Documentation]
#    ...  create an app with tcp:22
#    ...  create an app instance
#    ...  verify internal and public port is 10000
#
#    ${cluster_instance_default}=  Get Default Cluster Name
#
#    Create App  access_ports=tcp:22
#    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
#    ${version}=  Set Variable  ${appInst.key.app_key.version}
#    ${version}=  Remove String  ${version}  .
#
#    ${app_default}=  Get Default App Name
#    ${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -
#
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  22
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    10000
#    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
#    Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}
#
#    Length Should Be   ${appInst.mapped_ports}  1
#
#    Run Keyword Unless  (${epoch_time}-90) < ${appInst.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
#    Run Keyword Unless  ${appInst.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1233
AppInst - user shall be able to allocate public port tcp:18889
    [Documentation]
    ...  create an app with tcp:18889
    ...  create an app instance
    ...  verify internal and public port is 18889

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:18889
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  18889
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    18889
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-1234
AppInst - user shall be able to allocate public port tcp:18888
    [Documentation]
    ...  create an app with tcp:18888
    ...  create an app instance
    ...  verify internal and public port is 18888

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=tcp:18888
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  tcp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  18888
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    18888
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst.created_at.nanos} > 0  Fail  # verify has number greater than 0

# ECQ-2429
AppInst - User shall be able to add/delete dedicated/shared app/appInst with same TCP port
    [Documentation]
    ...  - create an app1 and appInst1 with shared (port not mapped)
    ...  - create an app2 and appInst2 with dedicated  (port not mapped)
    ...  - delete the appInst2
    ...  - create appInst2 again with shared  (port IS mapped)
    ...  - verify ports are mapped properly

    ${cluster_instance_default}=  Get Default Cluster Name
    ${app_name_1}=  Get Default App Name
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_name_1}  2

    # create app1 and appIns 1
    Create App  app_name=${app_name_1}  access_ports=tcp:1  deployment=kubernetes  access_type=loadbalancer
    ${appInst_1}=  Create App Instance  app_name=${app_name_1}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${cluster_instance_default}  autocluster_ip_access=IpAccessShared  #no_auto_delete=${True}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    Create App  app_name=${app_name_2}  access_ports=tcp:1
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${cluster_instance_default}2  autocluster_ip_access=IpAccessDedicated  no_auto_delete=${True}

    Delete App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${cluster_instance_default}2

    # create appInst again
    ${appInst_2_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster${cluster_instance_default}2  autocluster_ip_access=IpAccessShared

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  tcp  -

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    #Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Match Regexp   '${appInst_2.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2_2.mapped_ports[0].internal_port}  1
    #Should Be Equal As Integers  ${appInst_2_2.mapped_ports[0].public_port}    10000
    Should Match Regexp   '${appInst_2_2.mapped_ports[0].public_port}'   \\b\\d{5}\\b
    Should Be Equal As Integers  ${appInst_2_2.mapped_ports[0].proto}          1  #LProtoTCP
    #Should Be Equal              ${appInst_2_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

    Run Keyword Unless  (${epoch_time}-90) < ${appInst_1.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_1.created_at.nanos} > 0  Fail  # verify has number greater than 0
    Run Keyword Unless  (${epoch_time}-90) < ${appInst_2.created_at.seconds} < (${epoch_time}+90)  Fail  # verify created_at is within 1 minute
    Run Keyword Unless  ${appInst_2.created_at.nanos} > 0  Fail  # verify has number greater than 0

*** Keywords ***
Setup
    ${epoch}=  Get Current Date  result_format=epoch
    #Create Developer
    Create Flavor
    #Create Cluster  
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cluster_name=cluster${epoch}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
    Log To Console  Done Creating Cluster Instance

    ${epoch_time}=  Get Time  epoch

    Set Suite Variable  ${epoch_time}
