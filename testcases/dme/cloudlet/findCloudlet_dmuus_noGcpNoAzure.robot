*** Settings ***
Documentation   FindCloudlet - request shall return dmuus with no gcp/azure cloudlet provisioned

Library         MexDme  dme_address=${dme_api_address}

#Test Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0
${carrier_name}  dmuus

*** Test Cases ***
findCloudlet with same coord as tmocloud-1
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${carrier_name}  latitude=31  longitude=-91

      Should Be Equal             ${cloudlet.FQDN}  tmocloud-1.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  31.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -91.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  80
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  10000

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}  3  #LProtoHTTP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  443
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}  443

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}  2  #LProtoUDP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  10002
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}  10002

findCloudlet with same coord as tmocloud-2
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${carrier_name}  latitude=35  longitude=-95

      Should Be Equal             ${cloudlet.FQDN}  tmocloud-2.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  35.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -95.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  80
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  10000

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}  3  #LProtoHTTP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  443
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}  443

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}  2  #LProtoUDP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  10002
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}  10002

findCloudlet with coord closer to tmocloud-1
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${carrier_name}  latitude=23  longitude=-4

      Should Be Equal             ${cloudlet.FQDN}  tmocloud-1.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  31.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -91.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  80
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  10000

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}  3  #LProtoHTTP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  443
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}  443

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}  2  #LProtoUDP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  10002
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}  10002

findCloudlet with coord closer to tmocloud-2
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${carrier_name}  latitude=35  longitude=-96

      Should Be Equal             ${cloudlet.FQDN}  tmocloud-2.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  35.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -95.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  80
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  10000

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}  3  #LProtoHTTP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  443
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}  443

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}  2  #LProtoUDP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  10002
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}  10002

findCloudlet with coord max distance
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${carrier_name}  latitude=35000000000  longitude=-96000000000

      Should Be Equal             ${cloudlet.FQDN}  tmocloud-2.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  35.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -95.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  80
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  10000

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}  3  #LProtoHTTP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  443
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}  443

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}  2  #LProtoUDP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  10002
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}  10002

findCloudlet with coord 0
      Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}
      ${cloudlet}=  Find Cloudlet	carrier_name=${carrier_name}  latitude=0  longitude=0

      Should Be Equal             ${cloudlet.FQDN}  tmocloud-1.dmuus.mobiledgex.net
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  31.0
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  -91.0

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  80
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  10000

      Should Be Equal As Numbers  ${cloudlet.ports[1].proto}  3  #LProtoHTTP
      Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  443
      Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}  443

      Should Be Equal As Numbers  ${cloudlet.ports[2].proto}  2  #LProtoUDP
      Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  10002
      Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}  10002