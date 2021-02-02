*** Settings ***
Documentation   FindCloudlet - request shall return proper cloudlet when multiple cloudlets exist
...		dmuus tmocloud-1 cloudlet at: 31 -91
...		dmuus tmocloud-2 cloudlet at: 35 -95
...		dmuus tmocloud-3 cloudlet at: 35 -96
...		dmuus tmocloud-4 cloudlet at: 35 -97
...		dmuus tmocloud-5 cloudlet at: 35 -98
...		dmuus tmocloud-6 cloudlet at: 35 -99
...		dmuus tmocloud-7 cloudlet at: 35 -100
...		dmuus tmocloud-8 cloudlet at: 35 -101
...		dmuus tmocloud-9 cloudlet at: 35 -102
...		dmuus tmocloud-10 cloudlet at: 35 -103
...             azure azurecloud-1  cloudlet at: 35 -93
...             gcp gcpcloud-1  cloudlet at: 35 -105
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

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${gcp_operator_name}  gcp
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name2}  tmocloud-2  #has to match crm process startup parms
${dmuus_cloudlet_name1}  tmocloud-1  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
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
${dmuus_cloudlet_latitude1}	  31
${dmuus_cloudlet longitude1}	  -91
${dmuus_cloudlet_latitude2}	  35
${dmuus_cloudlet longitude2}	  -95

*** Test Cases ***
FindCloudlet - request shall return proper cloudlet when multiple cloudlets exist
    [Documentation]
    ...  findCloudlet with 10 dmuus and 1 azure/gcp cloudlet provisioned. verify returns proper cloudlet
    ...             dmuus tmocloud-1 cloudlet at: 31 -91
    ...             dmuus tmocloud-2 cloudlet at: 35 -95
    ...             dmuus tmocloud-3 cloudlet at: 35 -96
    ...             dmuus tmocloud-4 cloudlet at: 35 -97
    ...             dmuus tmocloud-5 cloudlet at: 35 -98
    ...             dmuus tmocloud-6 cloudlet at: 35 -99
    ...             dmuus tmocloud-7 cloudlet at: 35 -100
    ...             dmuus tmocloud-8 cloudlet at: 35 -101
    ...             dmuus tmocloud-9 cloudlet at: 35 -102
    ...             dmuus tmocloud-10 cloudlet at: 35 -103
    ...             azure azurecloud-1  cloudlet at: 35 -93
    ...             gcp gcpcloud-1  cloudlet at: 35 -105
    ...
    ...             find cloudlet closest to   : 31 -91
    ...             find cloudlet closest to   : 35 -92
    ...             find cloudlet closest to   : 35 -93
    ...             find cloudlet closest to   : 35 -94
    ...             find cloudlet closest to   : 35 -95
    ...             find cloudlet closest to   : 35 -96
    ...             find cloudlet closest to   : 35 -97
    ...             find cloudlet closest to   : 35 -98
    ...             find cloudlet closest to   : 35 -99
    ...             find cloudlet closest to   : 35 -100
    ...             find cloudlet closest to   : 35 -101
    ...             find cloudlet closest to   : 35 -102
    ...             find cloudlet closest to   : 35 -103
    ...             find cloudlet closest to   : 35 -104
    ...             find cloudlet closest to   : 35 -105
    ...             find cloudlet closest to   : 35 -106
    ...             find cloudlet closest to   : 35 -107

      [Template]  Find Cloudlet for dmuus closest to latitude ${lat} longitude ${long} should return ${expected_cloudlet} with latitude ${expected_lat} longitude ${expected_long}
          31  -91   ${appinst_1.uri}      31  -91
          35  -92   ${appinst_azure.uri}  35  -93
          35  -93   ${appinst_azure.uri}  35  -93
          35  -94   ${appinst_2.uri}      35  -95
          35  -95   ${appinst_2.uri}      35  -95
          35  -96   ${appinst_3.uri}      35  -96
          35  -97   ${appinst_4.uri}      35  -97
          35  -98   ${appinst_5.uri}      35  -98
          35  -99   ${appinst_6.uri}      35  -99
          35  -100  ${appinst_7.uri}      35  -100
          35  -101  ${appinst_8.uri}      35  -101
          35  -102  ${appinst_9.uri}      35  -102
          35  -103  ${appinst_10.uri}     35  -103
          35  -104  ${appinst_10.uri}     35  -103  #dmuus=91.09  gcp=91.09      diff=0 return dmuus
          35  -105  ${appinst_gcp.uri}    35  -105  #dmuus=182.17 gcp=0  diff=182.17      return gcp
          35  -106  ${appinst_gcp.uri}    35  -105   #dmuus=273.25 gcp=91.09 diff=182.16  return gcp
          35  -107  ${appinst_gcp.uri}    35  -105   #dmuus=364.32 gcp=182.17 diff=182.15 return gcp

*** Keywords ***
Find Cloudlet for dmuus closest to latitude ${lat} longitude ${long} should return ${expected_cloudlet} with latitude ${expected_lat} longitude ${expected_long}
      ${cloudlet}=  Find Cloudlet	carrier_name=${dmuus_operator_name}  latitude=${lat}  longitude=${long}

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${expected_cloudlet}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}  ${expected_lat}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${expected_long}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}  1  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  8888
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}  8888
    
    
Setup
    ${epoch}=  Get Time  epoch
    ${t3}=  Catenate  SEPARATOR=  tmocloud-3  ${epoch}
    ${t4}=  Catenate  SEPARATOR=  tmocloud-4  ${epoch}
    ${t5}=  Catenate  SEPARATOR=  tmocloud-5  ${epoch}
    ${t6}=  Catenate  SEPARATOR=  tmocloud-6  ${epoch}
    ${t7}=  Catenate  SEPARATOR=  tmocloud-7  ${epoch}
    ${t8}=  Catenate  SEPARATOR=  tmocloud-8  ${epoch}
    ${t9}=  Catenate  SEPARATOR=  tmocloud-9  ${epoch}
    ${t10}=  Catenate  SEPARATOR=  tmocloud-10  ${epoch}
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}
    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}


    #Create Developer            
    Create Flavor

    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    Create Cloudlet		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name1}  operator_org_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude1}  longitude=${dmuus_cloudlet_longitude1}
    #Create Cloudlet		cloudlet_name=${dmuus_cloudlet_name2}  operator_org_name=${dmuus_operator_name}  latitude=${dmuus_cloudlet_latitude2}  longitude=${dmuus_cloudlet_longitude2}
    Create Cloudlet		cloudlet_name=${t3}  operator_org_name=dmuus  latitude=35  longitude=-96
    Create Cloudlet		cloudlet_name=${t4}  operator_org_name=dmuus  latitude=35  longitude=-97
    Create Cloudlet		cloudlet_name=${t5}  operator_org_name=dmuus  latitude=35  longitude=-98
    Create Cloudlet		cloudlet_name=${t6}  operator_org_name=dmuus  latitude=35  longitude=-99
    Create Cloudlet		cloudlet_name=${t7}  operator_org_name=dmuus  latitude=35  longitude=-100
    Create Cloudlet		cloudlet_name=${t8}  operator_org_name=dmuus  latitude=35  longitude=-101
    Create Cloudlet		cloudlet_name=${t9}  operator_org_name=dmuus  latitude=35  longitude=-102
    Create Cloudlet		cloudlet_name=${t10}  operator_org_name=dmuus  latitude=35  longitude=-103
    #Create Cluster		
    Create App			access_ports=tcp:8888  
    ${appinst_1}=               Create App Instance		cloudlet_name=${dmuus_cloudlet_name1}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_2}=               Create App Instance		cloudlet_name=${dmuus_cloudlet_name2}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_3}=               Create App Instance		cloudlet_name=${t3}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_4}=               Create App Instance		cloudlet_name=${t4}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_5}=               Create App Instance		cloudlet_name=${t5}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_6}=               Create App Instance		cloudlet_name=${t6}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_7}=               Create App Instance		cloudlet_name=${t7}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_8}=               Create App Instance		cloudlet_name=${t8}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_9}=               Create App Instance		cloudlet_name=${t9}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_10}=              Create App Instance		cloudlet_name=${t10}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${appinst_azure}=           Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster
    ${appinst_gcp}=             Create App Instance		cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster
    Register Client	

    Set Suite Variable  ${appinst_azure} 
    Set Suite Variable  ${appinst_gcp} 
    Set Suite Variable  ${appinst_1} 
    Set Suite Variable  ${appinst_2} 
    Set Suite Variable  ${appinst_3} 
    Set Suite Variable  ${appinst_4} 
    Set Suite Variable  ${appinst_5} 
    Set Suite Variable  ${appinst_6} 
    Set Suite Variable  ${appinst_7} 
    Set Suite Variable  ${appinst_8} 
    Set Suite Variable  ${appinst_9} 
    Set Suite Variable  ${appinst_10} 
