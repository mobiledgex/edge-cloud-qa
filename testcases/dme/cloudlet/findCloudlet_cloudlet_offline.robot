*** Settings ***
Documentation   FindCloudlet with different cloudlet states

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${gcp_operator_name}  gcp
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95
${dmuus_cloudlet_latitude}	  35
${dmuus_cloudlet longitude}	  -95

${region}=  US

@{cloudlet_states}=  CloudletStateUnknown  CloudletStateErrors  CloudletStateOffline  CloudletStateNotPresent  CloudletStateInit  CloudletStateUpgrade  CloudletStateNeedSync
 

*** Test Cases ***
# ECQ-2438
FindCloudlet - request shall not return cloudlet if state=CloudletStateOffline
    [Documentation]
    ...  - CreateCloudlet and do RegisterClient/FindCloudlet
    ...  - verify returns dmuus cloudlet
    ...  - Set cloudlet to non Ready state
    ...  - do FindCloudlet and verify it returns gcp cloudlet
    ...  - set cloudlet to CloudletStateReady
    ...  - do FindCloudlet and verify it returns dmuus cloudlet again 
    ...  - repeat for all cloudlet states 
    ...  findCloudlet with with dmuus and gcp. dmuus farther but < 100km from request. return dmuus
    ...		dmuus tmocloud-2 cloudlet at: 35 -95
    ...         gcp gcpcloud-1  cloudlet at: 37 -95
    ...		find cloudlet closest to   : 36 -96
    ...                143.38km from dmuus
    ...                142.67km  from gcp
    ...             dmuus farther than gcp but less than 100km closer. return dmuus cloudlet
    ...
    ...             ShowCloudlet
    ...             - key:
    ...                 operatorkey:
    ...                   name: dmuus
    ...                 name: tmocloud-2
    ...               location:
    ...                 lat: 35
    ...                 long: -95
    ...             - key:
    ...                 operatorkey:
    ...                   name: gcp
    ...                 name: gcpcloud-1
    ...               location:
    ...                 lat: 37
    ...                 long: -95

      Register Client	
      ${cloudlet}=  Find Cloudlet	carrier_name=${dmuus_operator_name}  latitude=36  longitude=-96

      Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

      Should Be Equal             ${cloudlet.fqdn}  ${dmuus_appinst['data']['uri']}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${dmuus_cloudlet_latitude}
      Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${dmuus_cloudlet_longitude}

      Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${dmuus_appinst['data']['mapped_ports'][0]['proto']}  #LProtoTCP
      Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${dmuus_appinst['data']['mapped_ports'][0]['internal_port']}
      Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${dmuus_appinst['data']['mapped_ports'][0]['public_port']}

      Should Be True  len('${cloudlet.edge_events_cookie}') > 100

      FOR  ${state}  IN  @{cloudlet_states}
         # set dmuus cloudlet offline
         Show Cloudlet Info    region=${region}  cloudlet_name=${cloudlet_name_default}  #token=${super_token}  use_defaults=${False}
         Inject Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name_default}  operator_org_name=${dmuus_operator_name}  state=${state}
         # should return gcp cloudlet since dmuus is offline
         ${cloudlet2}=  Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=36  longitude=-96
         Should Be Equal As Numbers  ${cloudlet2.status}  1  #FIND_FOUND
         Should Be Equal             ${cloudlet2.fqdn}  ${gcp_appinst['data']['uri']}

         # set dmuus cloudlet back online
         Inject Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name_default}  operator_org_name=${dmuus_operator_name}  state=CloudletStateReady
         # should return dmuus cloudlet since dmuus is ready
         ${cloudlet3}=  Find Cloudlet       carrier_name=${dmuus_operator_name}  latitude=36  longitude=-96
         Should Be Equal As Numbers  ${cloudlet3.status}  1  #FIND_FOUND
         Should Be Equal             ${cloudlet3.fqdn}  ${dmuus_appinst['data']['uri']}
      END
*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}

    ${cloudlet_name_default}=  Get Default Cloudlet Name

    Create Flavor  region=${region}
    Create Cloudlet  region=${region}  cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name_default}  operator_org_name=dmuus  latitude=35  longitude=-95

    Create App  region=${region}  access_ports=tcp:1
    ${dmuus_appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_default}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster
    ${gcp_appinst}=   Create App Instance  region=${region}  cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${dmuus_appinst} 
    Set Suite Variable  ${gcp_appinst}
    Set Suite Variable  ${cloudlet_name_default}

Teardown
    Inject Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name_default}  operator_org_name=${dmuus_operator_name}  state=CloudletStateReady
    Cleanup Provisioning
