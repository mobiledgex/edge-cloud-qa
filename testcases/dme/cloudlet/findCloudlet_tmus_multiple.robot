*** Settings ***
Documentation   FindCloudlet - request shall return proper cloudlet when multiple cloudlets exist
...		tmus tmocloud-1 cloudlet at: 31 -91
...		tmus tmocloud-2 cloudlet at: 35 -95
...		tmus tmocloud-3 cloudlet at: 35 -96
...		tmus tmocloud-4 cloudlet at: 35 -97
...		tmus tmocloud-5 cloudlet at: 35 -98
...		tmus tmocloud-6 cloudlet at: 35 -99
...		tmus tmocloud-7 cloudlet at: 35 -100
...		tmus tmocloud-8 cloudlet at: 35 -101
...		tmus tmocloud-9 cloudlet at: 35 -102
...		tmus tmocloud-10 cloudlet at: 35 -103
...             azure tmocloud-2  cloudlet at: 35 -93
...             gcp tmocloud-2  cloudlet at: 35 -105
...
...		find cloudlet closest to   : 31 -91
...		find cloudlet closest to   : 35 -92
...		find cloudlet closest to   : 35 -93
...		find cloudlet closest to   : 35 -94
...		find cloudlet closest to   : 35 -95
...		find cloudlet closest to   : 35 -96
...		find cloudlet closest to   : 35 -97
...		find cloudlet closest to   : 35 -98
...		find cloudlet closest to   : 35 -99
...		find cloudlet closest to   : 35 -100
...		find cloudlet closest to   : 35 -101
...		find cloudlet closest to   : 35 -102
...		find cloudlet closest to   : 35 -103
...		find cloudlet closest to   : 35 -104
...		find cloudlet closest to   : 35 -105
...		find cloudlet closest to   : 35 -106
...		find cloudlet closest to   : 35 -107

Library         MexDme  dme_address=${dme_api_address}
Library		MexController  controller_address=${controller_api_address}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${controller_api_address}  127.0.0.1:55001
${public_azure_operator_name}  azure
${public_gcp_operator_name}  gcp
${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${cloudlet_name1}  tmocloud-1  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${azure_cloudlet_latitude}	  35
${azure_cloudlet longitude}	  -93
${gcp_cloudlet_latitude}	  35
${gcp_cloudlet longitude}	  -105

*** Test Cases ***
findCloudlet with with tmus and azure same distance
      [Template]  Find Cloudlet for tmus closest to latitude ${lat} longitude ${long} should return ${expected_cloudlet} with latitude ${expected_lat} longitude ${expected_long}
          31  -91  acmeappcosomeapplication210.tmocloud-1.tmus.mobiledgex.net  31  -91
          35  -92  acmeappcosomeapplication210.tmocloud-2.azure.mobiledgex.net  35  -93
          35  -93  acmeappcosomeapplication210.tmocloud-2.azure.mobiledgex.net  35  -93
          35  -94  acmeappcosomeapplication210.tmocloud-2.tmus.mobiledgex.net  35  -95
          35  -95  acmeappcosomeapplication210.tmocloud-2.tmus.mobiledgex.net  35  -95
          35  -96  acmeappcosomeapplication210.tmocloud-3.tmus.mobiledgex.net  35  -96
          35  -97  acmeappcosomeapplication210.tmocloud-4.tmus.mobiledgex.net  35  -97
          35  -98  acmeappcosomeapplication210.tmocloud-5.tmus.mobiledgex.net  35  -98
          35  -99  acmeappcosomeapplication210.tmocloud-6.tmus.mobiledgex.net  35  -99
          35  -100  acmeappcosomeapplication210.tmocloud-7.tmus.mobiledgex.net  35  -100
          35  -101  acmeappcosomeapplication210.tmocloud-8.tmus.mobiledgex.net  35  -101
          35  -102  acmeappcosomeapplication210.tmocloud-9.tmus.mobiledgex.net  35  -102
          35  -103  acmeappcosomeapplication210.tmocloud-10.tmus.mobiledgex.net  35  -103
          35  -104  acmeappcosomeapplication210.tmocloud-10.tmus.mobiledgex.net  35  -103  #tmus=91.09  gcp=91.09      diff=0 return tmus
          35  -105  acmeappcosomeapplication210.tmocloud-2.gcp.mobiledgex.net  35  -105  #tmus=182.17 gcp=0  diff=182.17      return gcp
          35  -106  acmeappcosomeapplication210.tmocloud-2.gcp.mobiledgex.net  35  -105   #tmus=273.25 gcp=91.09 diff=182.16  return gcp
          35  -107  acmeappcosomeapplication210.tmocloud-2.gcp.mobiledgex.net  35  -105   #tmus=364.32 gcp=182.17 diff=182.15 return gcp

*** Keywords ***
Find Cloudlet for tmus closest to latitude ${lat} longitude ${long} should return ${expected_cloudlet} with latitude ${expected_lat} longitude ${expected_long}
      ${cloudlet}=  Find Cloudlet	carrier_name=${operator_name}  latitude=${lat}  longitude=${long}

      Should Be Equal             ${cloudlet.FQDN}  ${expected_cloudlet}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.lat}  ${expected_lat}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.long}  ${expected_long}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  1
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  1
    
    
Setup
    Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${public_azure_operator_name}  number_of_dynamic_ips=default  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${public_gcp_operator_name}  number_of_dynamic_ips=default  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=tmocloud-3  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-96
    Create Cloudlet		cloudlet_name=tmocloud-4  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-97
    Create Cloudlet		cloudlet_name=tmocloud-5  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-98
    Create Cloudlet		cloudlet_name=tmocloud-6  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-99
    Create Cloudlet		cloudlet_name=tmocloud-7  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-100
    Create Cloudlet		cloudlet_name=tmocloud-8  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-101
    Create Cloudlet		cloudlet_name=tmocloud-9  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-102
    Create Cloudlet		cloudlet_name=tmocloud-10  operator_name=tmus  number_of_dynamic_ips=default  latitude=35  longitude=-103
    Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}

    Create Cluster		cluster_name=default  default_flavor_name=${flavor}
    Create App			app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-3  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-4  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-5  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-6  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-7  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-8  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-9  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=tmocloud-10  operator_name=${operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${public_azure_operator_name}
    Create App Instance		app_name=${app_name}  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${public_gcp_operator_name}
    Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}