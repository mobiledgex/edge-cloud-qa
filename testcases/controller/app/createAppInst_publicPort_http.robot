*** Settings ***
Documentation   CreateAppInst public port HTTP

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	

Library         String
	
Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1
${cloudlet_name_2}  tmocloud-2
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
AppInst - user shall be able to add 1 HTTP port
    [Documentation]
    ...  create an app with http:1
    ...  create an app instance
    ...  verify internal and public port is 443 and public_path is correct
	
    Create App  access_ports=http:1
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${public_path}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p1

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          3  #LProtoUDP
    Should Be Equal              ${appInst.mapped_ports[0].path_prefix}    ${public_path}

    Length Should Be   ${appInst.mapped_ports}  1


AppInst - user shall be able to add 10 HTTP ports
    [Documentation]
    ...  create an app with http:1 thru 10
    ...  create an app instance
    ...  verify public port is 443 and public_path is correct

    Create App  access_ports=http:1,http:2,http:3,http:4,http:5,http:6,http:7,http:8,http:9,http:10
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${public_path_1}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p1
    ${public_path_2}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p2
    ${public_path_3}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p3
    ${public_path_4}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p4
    ${public_path_5}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p5
    ${public_path_6}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p6
    ${public_path_7}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p7
    ${public_path_8}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p8
    ${public_path_9}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p9
    ${public_path_10}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p10

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[0].path_prefix}    ${public_path_1}

    Should Be Equal As Integers  ${appInst.mapped_ports[1].internal_port}  2
    Should Be Equal As Integers  ${appInst.mapped_ports[1].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[1].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[1].path_prefix}    ${public_path_2}

    Should Be Equal As Integers  ${appInst.mapped_ports[2].internal_port}  3
    Should Be Equal As Integers  ${appInst.mapped_ports[2].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[2].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[2].path_prefix}    ${public_path_3}

    Should Be Equal As Integers  ${appInst.mapped_ports[3].internal_port}  4
    Should Be Equal As Integers  ${appInst.mapped_ports[3].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[3].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[3].path_prefix}    ${public_path_4}

    Should Be Equal As Integers  ${appInst.mapped_ports[4].internal_port}  5
    Should Be Equal As Integers  ${appInst.mapped_ports[4].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[4].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[4].path_prefix}    ${public_path_5}

    Should Be Equal As Integers  ${appInst.mapped_ports[5].internal_port}  6
    Should Be Equal As Integers  ${appInst.mapped_ports[5].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[5].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[5].path_prefix}    ${public_path_6}

    Should Be Equal As Integers  ${appInst.mapped_ports[6].internal_port}  7
    Should Be Equal As Integers  ${appInst.mapped_ports[6].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[6].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[6].path_prefix}    ${public_path_7}

    Should Be Equal As Integers  ${appInst.mapped_ports[7].internal_port}  8
    Should Be Equal As Integers  ${appInst.mapped_ports[7].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[7].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[7].path_prefix}    ${public_path_8}

    Should Be Equal As Integers  ${appInst.mapped_ports[8].internal_port}  9
    Should Be Equal As Integers  ${appInst.mapped_ports[8].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[8].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[8].path_prefix}    ${public_path_9}

    Should Be Equal As Integers  ${appInst.mapped_ports[9].internal_port}  10
    Should Be Equal As Integers  ${appInst.mapped_ports[9].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[9].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[9].path_prefix}    ${public_path_10}

    Length Should Be   ${appInst.mapped_ports}  10

AppInst - 2 appInst on different app and same cluster and same cloudlet shall be able to allocate the same HTTP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
    ...  create an app2 and appInst2 on cluster1 cloudlet1 with http:1
    ...  verify app1 public port is 443 and public_path is correct
    ...  verify app2 public port is 443 and public_path is correct

    # create app1 and appIns 1
    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=   Get Default App Name
    ${app_default_2}=   Catenate  SEPARATOR=-  ${app_default_1}  2
    ${public_path_1}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1
    ${public_path_2}=   Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_2}${version_default}  p1

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=http:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    # verify app1 uses port 1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be             ${appInst_1.mapped_ports}                   1

    # verify app2 uses port 10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_2}
    Length Should Be             ${appInst_2.mapped_ports}                   1

AppInst - 2 appInst on different app and different cluster and same cloudlet shall be able to allocate the same HTTP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with http:1
    ...  verify app1 public port is 443 and public_path is correct
    ...  verify app2 internal port is 1 and public port is 443 and public_path is correct

    # create app1 and appIns 1
    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1
    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    ${public_path_2}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_2}${version_default}  p1

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=http:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be             ${appInst_1.mapped_ports}                   1

    # verify app2 uses port 443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_2}
    Length Should Be             ${appInst_2.mapped_ports}                   1

AppInst - 2 appInst on different app/cluster/cloudlet shall be able to allocate the same HTTP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
    ...  create an app2 and appInst2 on cluster2 cloudlet2 with http:1
    ...  verify app1 public port is 443 and public_path is correct
    ...  verify app2 public port is 443 and public_path is correct

    # create app1 and appIns 1
    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1

    ${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    ${public_path_2}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_2}${version_default}  p1

    # create app2 and appInst on the same port
    Create App  app_name=${app_default_2}  access_ports=http:1
    ${appInst_2}=  Create App Instance  app_name=${app_default_2}  cloudlet_name=${cloudlet_name_2}  operator_name=${operator_name}  cluster_instance_name=autocluster

    # verify app1 uses port 443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be             ${appInst_1.mapped_ports}                   1

    # verify app2 uses port 443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_2}
    Length Should Be             ${appInst_2.mapped_ports}                   1

AppInst - 2 appInst on same app and different cluster and same cloudlet shall be able to allocate the same HTTP port
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
    ...  create an app1 and appInst2 on cluster1 cloudlet1 with http:1
    ...  verify app1 public port is 443 and public_path is correct
    ...  verify app2 public port is 443 and public_path is correct

    # EDGECLOUD-414 trying to create 2 appinst on different cluster but same cloudlet

    ${epoch_time}=  Get Time  epoch
	
    # create app1 and appIns 1
    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1

    #${app_default_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    #${public_path_2}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_2}${version_default}  p1

    # create app2 and appInst on the same port
    #Create App  app_name=${app_default_2}  access_ports=tcp:1
    ${autocluster}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${autocluster}

    # verify app1 uses port 443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

# removed from stratus
#AppInst - 2 appInst on same app and different cluster and different cloudlet shall be able to allocate the same public HTTP port
#    [Documentation]
#    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
#    ...  create an app1 and appInst2 on cluster2 cloudlet2 with http:1
#    ...  verify app1 public port is 443 and public_path is correct
#    ...  verify app2 public port is 443 and public_path is correct
#
#    # create app1 and appIns 1
#    Create App  access_ports=http:1
#    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}
#
#
#    ${app_default_1}=  Get Default App Name
#    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1
#
#    Register Client  app_name=${app_default_1}
#    ${cloudlet_1}=  Find Cloudlet	latitude=31  longitude=-91
#
#    # create app2 and appInst on the same port
#    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name_2}  operator_name=${operator_name}  cluster_instance_name=autocluster
#
#    ${cloudlet_2}=  Find Cloudlet	latitude=35  longitude=-95
#
#    ${fqdn}=    Catenate  SEPARATOR=.  ${cloudlet_name}    ${operator_name}  mobiledgex.net
#    ${fqdn_2}=  Catenate  SEPARATOR=.  ${cloudlet_name_2}  ${operator_name}  mobiledgex.net
#    
#    Should Be Equal              ${cloudlet_1.fqdn}  ${fqdn}
#    Should Be Equal              ${cloudlet_2.fqdn}  ${fqdn_2}
#	
#    # verify app1 uses port 443
#    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
#    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
#    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
#    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
#    Length Should Be   ${appInst_1.mapped_ports}  1
#
#    # verify app2 uses port 443
#    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
#    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
#    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
#    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_1}
#    Length Should Be   ${appInst_2.mapped_ports}  1

AppInst - User shall be able to add app/appInst, delete, and readd with same HTTP port
    [Documentation]
    ...  create an app1 and appInst1 
    ...  delete the appInst
    ...  readd the appInst
    ...  verify it gets public port 443

    # create app1 and appIns 1
    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}  no_auto_delete=${True}

    Delete App Instance

    # create appInst again
    ${appInst_2}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1

    # verify app1 uses port 443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_2.mapped_ports}  1

AppInst - User shall be able to add app, udpate app, add appInst with same HTTP port
    [Documentation]
    ...  create an app1 with http:1
    ...  update app with http:2
    ...  add the appInst
    ...  verify it gets the same public port 443

    ${cluster_instance_default}=  Get Default Cluster Name

    # create app1 and update app
    Create App  access_ports=http:1,http:2
    Update App  access_ports=http:3,http:4

    # create appInst
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p3
    ${public_path_2}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p4

    # verify app1 uses port 443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  3
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].internal_port}  4
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[1].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[1].path_prefix}    ${public_path_2}

    Length Should Be   ${appInst_1.mapped_ports}  2

AppInst - 3 appInst on different app and different cluster and different cloudlet shall be able to allocate HTTP port 10000
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with http:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with http:10000
    ...  verify app1 public port is 443
    ...  verify app2 public port is 443
    ...  verify app3 public port is 443

    ${epoch_time}=  Get Time  epoch

    # create app1 and appIns 1
    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p1

    # create appInst2 on the same port
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    ${public_path_2}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_name_2}${version_default}  p1
    ${autocluster_2}=  Catenate  SEPARATOR=-  autocluster  2
    Create App  app_name=${app_name_2}  access_ports=http:1
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${autocluster_2}


    # create appInst4 on the port 10000
    ${app_name_3}=  Catenate  SEPARATOR=-  ${app_default_1}  3
    ${public_path_3}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_name_3}${version_default}  p10000
    ${autocluster_3}=  Catenate  SEPARATOR=-  autocluster  3
    Create App  app_name=${app_name_3}  access_ports=http:10000
    ${appInst_3}=  Create App Instance  app_name=${app_name_3}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${autocluster_3}

    # verify app1 uses port 443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

    # verify app2 uses port 443
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].internal_port}  10000
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_3.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_3.mapped_ports[0].path_prefix}    ${public_path_3}
    Length Should Be   ${appInst_3.mapped_ports}  1

AppInst - appInst shall allocate HTTP port 10000 if already allocated
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:10000
    ...  create an app2 and appInst3 on cluster3 cloudlet1 with http:10000
    ...  verify app1 public port is 443
    ...  verify app2 internal port is 10000 and public port is 443

    # create app1 and appIns 1
    Create App  access_ports=http:10000
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default_1}=  Get Default App Name
    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default_1}${version_default}  p10000

    # create appInst2 on the same port
    ${app_name_2}=  Catenate  SEPARATOR=-  ${app_default_1}  2
    ${public_path_2}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_name_2}${version_default}  p10000
    Create App  app_name=${app_name_2}  access_ports=http:10000
    ${appInst_2}=  Create App Instance  app_name=${app_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster


    # verify app1 uses port 10000
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  10000
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    # verify app2 uses port 10001
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].internal_port}  10000
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_2.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_2.mapped_ports[0].path_prefix}    ${public_path_2}
    Length Should Be   ${appInst_2.mapped_ports}  1

AppInst - user shall be to add multiple HTTP public ports
    [Documentation]
    ...  create an app1 and appInst1 on cluster1 cloudlet1 with http:1
    ...  create an app2 and appInst2 on cluster2 cloudlet1 with http:1
    ...  create an app3 and appInst3 on cluster3 cloudlet1 with http:10000
    ...  verify app1 public port is 443
    ...  verify app2 internal port is 1 and public port is 443
    ...  verify app3 internal port is 10000 and public port is 443

    # create app1 and appIns 1
    ${app_default}=  Get Default App Name

    Create App  access_ports=http:1
    ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    Length Should Be   ${appInst_1.mapped_ports}  1

    FOR  ${index}  IN RANGE  0  100
    \   ${app_name}=  Catenate  SEPARATOR=-  ${app_default}  ${index}
    \   Create App  app_name=${app_name}  access_ports=http:1
    \   ${appInst_1}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    \   
    \   ${public_path_1}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_name}${version_default}  p1
    \   # verify app1 uses port 443
    \   Should Be Equal As Integers  ${appInst_1.mapped_ports[0].internal_port}  1
    \   Should Be Equal As Integers  ${appInst_1.mapped_ports[0].public_port}    443
    \   Should Be Equal As Integers  ${appInst_1.mapped_ports[0].proto}          3  #LProtoTCP
    \   Should Be Equal              ${appInst_1.mapped_ports[0].path_prefix}    ${public_path_1}
    \   Length Should Be   ${appInst_1.mapped_ports}  1

AppInst - user shall be able to allocate port http:22
    [Documentation]
    ...  create an app with http:22
    ...  create an app instance
    ...  verify public port is 443

    Create App  access_ports=http:22
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${public_path}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p22

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  22
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[0].path_prefix}    ${public_path}

    Length Should Be   ${appInst.mapped_ports}  1

AppInst - user shall be able to allocate port http:18889
    [Documentation]
    ...  create an app with http:18889
    ...  create an app instance
    ...  verify public port is 443

    Create App  access_ports=http:18889
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${public_path}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p18889

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  18889
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[0].path_prefix}    ${public_path}

    Length Should Be   ${appInst.mapped_ports}  1

AppInst - user shall be able to allocate port http:18888
    [Documentation]
    ...  create an app with http:18888
    ...  create an app instance
    ...  verify public port is 443

    Create App  access_ports=http:18888
    ${appInst}=  Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_instance_default}

    ${app_default}=  Get Default App Name
    ${public_path}=  Catenate  SEPARATOR=/  ${developer_name_default}  ${app_default}${version_default}  p18888

    Should Be Equal As Integers  ${appInst.mapped_ports[0].internal_port}  18888
    Should Be Equal As Integers  ${appInst.mapped_ports[0].public_port}    443
    Should Be Equal As Integers  ${appInst.mapped_ports[0].proto}          3  #LProtoHTTP
    Should Be Equal              ${appInst.mapped_ports[0].path_prefix}    ${public_path}

    Length Should Be   ${appInst.mapped_ports}  1

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster  
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Log To Console  Done Creating Cluster Instance

    ${cluster_instance_default}=  Get Default Cluster Name
    ${developer_name_default}=    Get Default Developer Name
    ${version_default}=           Get Default App Version
    ${version_default}=           Remove String  ${version_default}  .

    Set Suite Variable  ${cluster_instance_default}
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${version_default}
