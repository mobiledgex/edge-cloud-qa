*** Settings ***
Documentation   CreateAppInst public port UDP

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
# ECQ-1235
AppInst - user shall be able to add 1 UDP port with same public port
    [Documentation]
    ...  create an app with udp:1
    ...  create an app instance
    ...  verify internal and public port is 1

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:1
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -
    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

# ECQ-1236
AppInst - user shall be able to add 10 UDP port with same public port
    [Documentation]
    ...  create an app with udp:1 thru 10
    ...  create an app instance
    ...  verify internal and public port is 1-10

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:1,udp:2,udp:3,udp:4,udp:5,udp:6,udp:7,udp:8,udp:9,udp:10
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[1].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[2].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[3].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[4].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[5].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[6].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[7].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[8].fqdn_prefix}    ${fqdn_prefix}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[9].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  10

# ECQ-1237
AppInst - 2 appInst on different app and same cluster and same cloudlet shall not be able to allocate the same public UDP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app2 and appInst2 on cluster1 cloudlet1 with udp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  udp  -

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=udp:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1238
AppInst - 2 appInst on different app and different cluster and same cloudlet shall not be able to allocate the same public UDP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with udp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  udp  -

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=udp:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1239
AppInst - 2 appInst on different app/cluster/cloudlet shall be able to allocate the same public UDP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet2 with udp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 1

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  ${version}  -  udp  -

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=udp:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1240
AppInst - 2 appInst on same app and different cluster and same cloudlet shall not be able to allocate the same public UDP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app1 and appInst2 on cluster1 cloudlet1 with udp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    # EDGECLOUD-414 trying to create 2 appinst on different cluster but same cloudlet

    ${epoch_time}=  Get Time  epoch
	
    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    #${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_default_2}  -  udp  -

    # create app2 and appInst on the same port
    #Create App  app_name=${app_default_2}  access_ports=tcp:1
    ${autocluster}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${autocluster}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1241
AppInst - 2 appInst on same app and different cluster and different cloudlet shall not be able to allocate the same public UDP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app1 and appInst2 on cluster2 cloudlet2 with udp:1
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    # create app2 and appInst on the same port
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1242
AppInst - User shall be able to add app/appInst, delete, and readd with same public UDP port
    [Documentation]
    ...  create an app1 and appInst1 
    ...  delete the appInst
    ...  readd the appInst
    ...  verify it gets the same public port

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}  no_auto_delete=${True}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .
    Delete App Instance

    # create appInst again
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1243
AppInst - User shall be able to add app, udpate app, add /appInst with same public UDP port
    [Documentation]
    ...  create an app1 with udp:1
    ...  update app with udp:2
    ...  add the appInst
    ...  verify it gets the same public port

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and update app
    Create App  access_ports=udp:1,udp:2
    Update App  access_ports=udp:3,udp:4

    # create appInst
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  3
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    3
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].internal_port}  4
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].public_port}    4
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[1].fqdn_prefix}    ${fqdn_prefix_1}

    Length Should Be   ${appInst_1.mapped_ports}  2

# ECQ-1244
AppInst - 3 appInst on different app and different cluster and different cloudlet shall not be able to allocate public UDP port 10000
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with udp:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with udp:10000
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000
    ...  verify app3 internal port is 10000 and public port is 10001

    ${epoch_time}=  Get Time  epoch

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    # create appInst2 on the same port
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_name_2}  ${version}  -  udp  -
    ${autocluster_2}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}   2
    Create App  app_name=${app_name_2}  access_ports=udp:1
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${autocluster_2}

    # create appInst4 on the port 10000
    ${app_name_3}=  Catenate  SEPARATOR=-  ${app_default_1}  3
    #${fqdn_prefix_3}=  Catenate  SEPARATOR=  ${app_name_3}  ${version}  -  udp  -
    ${autocluster_3}=  Catenate  SEPARATOR=  autocluster  ${epoch_time}   3
    Create App  app_name=${app_name_3}  access_ports=udp:10000
    ${appInst_3}=  Create App Instance  app_name=${app_name_3}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${autocluster_3}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    # verify app2 uses port 10001
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].internal_port}  10000
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].public_port}    10001
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_3.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_3}
    Length Should Be   ${appInst_3.mapped_ports}  1

# ECQ-1245
AppInst - appInst shall not allocate UDP port 10000 if already allocated
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with udp:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with udp:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with udp:10000
    ...  verify app1 internal and public port is 1
    ...  verify app2 internal port is 1 and public port is 10000
    ...  verify app3 internal port is 10000 and public port is 10001

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    Create App  access_ports=udp:10000
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default_1}=  Get Default App Name
    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default_1}  ${version}  -  udp  -

    # create appInst2 on the same port
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${fqdn_prefix_2}=  Catenate  SEPARATOR=  ${app_name_2}  ${version}  -  udp  -
    Create App  app_name=${app_name_2}  access_ports=udp:10000
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster


    # verify app1 uses port 10000
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  10000
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10001
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    10001
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst_2.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

# ECQ-1246
AppInst - user shall be to add multiple UDP public ports
    [Documentation]
    ...  create 100 UDP ports
    ...  verify 10000-10099 is created

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and appIns 1
    ${app_default}=  Get Default App Name

    Create App  access_ports=udp:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst_1.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoTCP
    #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    FOR  ${index}  IN RANGE  0  100
       ${app_name}=  Catenate  SEPARATOR=-  ${app_default}  ${index}
       Create App  app_name=${app_name}  access_ports=udp:1
       ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

       
       #${fqdn_prefix_1}=  Catenate  SEPARATOR=  ${app_name}  ${version}  -  udp  -
       ${public_port}=  Evaluate  10000 + ${index}
       # verify app1 uses port 1
       Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
       Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    ${public_port}
       Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          2  #LProtoUDP
       #Should Be Equal              ${appInst_1.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix_1}
       Length Should Be   ${appInst_1.mapped_ports}  1
    END

# ECQ-1247
AppInst - user shall not be able to allocate public port udp:22
    [Documentation]
    ...  create an app with udp:22
    ...  create an app instance
    ...  verify internal and public port is 10000

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:22
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  22
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    10000
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

# ECQ-1248
AppInst - user shall be able to allocate public port udp:18889
    [Documentation]
    ...  create an app with udp:18889
    ...  create an app instance
    ...  verify internal and public port is 18889

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:18889
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  18889
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    18889
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

# ECQ-1249
AppInst - user shall be able to allocate public port udp:18888
    [Documentation]
    ...  create an app with udp:18888
    ...  create an app instance
    ...  verify internal and public port is 18888

    ${cluster_instance_default}=  Get Default Cluster Name

    Create App  access_ports=udp:18888
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
    ${version}=  Set Variable  ${appInst.key.app_key.version}
    ${version}=  Remove String  ${version}  .

    ${app_default}=  Get Default App Name
    #${fqdn_prefix}=  Catenate  SEPARATOR=  ${app_default}  ${version}  -  udp  -

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  18888
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    18888
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          2  #LProtoUDP
    #Should Be Equal              ${appInst.mapped_ports[0].fqdn_prefix}    ${fqdn_prefix}

    Length Should Be   ${appInst.mapped_ports}  1

*** Keywords ***
Setup
    ${epoch}=  Get Current Date  result_format=epoch

    #Create Developer
    Create Flavor
    #Create Cluster  
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cluster_name=cluster${epoch}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
    Log To Console  Done Creating Cluster Instance
