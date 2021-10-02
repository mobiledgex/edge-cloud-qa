*** Settings ***
Documentation   GetAppInstList - request with alliance orgs

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Setup     Setup
Test Teardown  Cleanup provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name_1}  tmocloud-1
${cloudlet_name_2}  tmocloud-2
${cloudlet_name_3}  tmocloud-3
${cloudlet_name_4}  tmocloud-4
${cloudlet_name_5}  tmocloud-5
${cloudlet_name_6}  tmocloud-6

${mobile_latitude}  1
${mobile_longitude}  1

${distance_offset}=  100

${region}=  US

*** Test Cases ***
# ECQ-3986
GetAppInstList - request shall return appinst with alliance orgs
    [Documentation]
    ...  - CreateCloudlets with alliance orgs
    ...  - registerClient
    ...  - send GetAppInstList
    ...  - verify returns appinsts with requested carrier and alliance org

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus  GDDT
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name3}  operator_org_name=packet  latitude=3  longitude=3  alliance_org_list=${allianceorgs}
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name4}  operator_org_name=packet  latitude=4  longitude=4
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name5}  operator_org_name=packet  latitude=5  longitude=5  alliance_org_list=${allianceorgs}
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name6}  operator_org_name=att     latitude=6  longitude=6  alliance_org_list=${allianceorgs}

    ${dmuus_appinst_1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_3}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_4}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_4}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_5}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_5}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_6}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_6}  operator_org_name=att     cluster_instance_name=autocluster

    Register Client
    ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

    @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}

    # response is sorted by distance with shortest distance first

    Verify AppInst  ${appfqdns[0]}  ${dmuus_appinst_3}  ${origin}
    Verify AppInst  ${appfqdns[1]}  ${dmuus_appinst_5}  ${origin}
    Verify AppInst  ${appfqdns[2]}  ${dmuus_appinst_6}  ${origin}
    Verify AppInst  ${appfqdns[3]}  ${dmuus_appinst_1}  ${origin}
    Verify AppInst  ${appfqdns[4]}  ${dmuus_appinst_2}  ${origin}

    Length Should Be   ${appfqdns}  5

# ECQ-3987
GetAppInstList - request shall return appinsts with alliance orgs after UpdateCloudlet
    [Documentation]
    ...  - CreateCloudlets without alliance orgs
    ...  - registerClient
    ...  - send GetAppInstList and verify it only returns carrier requested
    ...  - UpdateCloudlet adding alliance orgs
    ...  - send GetAppInstList and verify returns appinsts with requested carrier and alliance org

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name3}  operator_org_name=packet  latitude=3  longitude=3
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name4}  operator_org_name=packet  latitude=4  longitude=4
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name5}  operator_org_name=packet  latitude=5  longitude=5

    ${dmuus_appinst_1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_3}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_4}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_4}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_5}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_5}  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client
    ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

    @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}

    # response is sorted by distance with shortest distance first

    Verify AppInst  ${appfqdns[0]}  ${dmuus_appinst_1}  ${origin}
    Verify AppInst  ${appfqdns[1]}  ${dmuus_appinst_2}  ${origin}

    Length Should Be   ${appfqdns}  2

    Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name3}  operator_org_name=packet  alliance_org_list=${allianceorgs}
    Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name5}  operator_org_name=packet  alliance_org_list=${allianceorgs}

    ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

    Verify AppInst  ${appfqdns[0]}  ${dmuus_appinst_3}  ${origin}
    Verify AppInst  ${appfqdns[1]}  ${dmuus_appinst_5}  ${origin}
    Verify AppInst  ${appfqdns[2]}  ${dmuus_appinst_1}  ${origin}
    Verify AppInst  ${appfqdns[3]}  ${dmuus_appinst_2}  ${origin}

    Length Should Be   ${appfqdns}  4

# ECQ-3988
GetAppInstList - request shall return appinsts with alliance orgs after AddAllianceOrg
    [Documentation]
    ...  - CreateCloudlets without alliance orgs
    ...  - registerClient
    ...  - send GetAppInstList and verify it only returns carrier requested
    ...  - AddAllianceOrg adding alliance orgs
    ...  - send GetAppInstList and verify returns appinsts with requested carrier and alliance org

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name3}  operator_org_name=packet  latitude=3  longitude=3
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name4}  operator_org_name=packet  latitude=4  longitude=4
    Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name5}  operator_org_name=packet  latitude=5  longitude=5

    ${dmuus_appinst_1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${dmuus_appinst_3}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_3}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_4}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_4}  operator_org_name=packet  cluster_instance_name=autocluster
    ${dmuus_appinst_5}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_5}  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client
    ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

    @{origin}=  Create List  ${mobile_latitude}  ${mobile_longitude}

    # response is sorted by distance with shortest distance first

    Verify AppInst  ${appfqdns[0]}  ${dmuus_appinst_1}  ${origin}
    Verify AppInst  ${appfqdns[1]}  ${dmuus_appinst_2}  ${origin}

    Length Should Be   ${appfqdns}  2

    Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet_name3}  operator_org_name=packet  alliance_org_name=dmuus
    Add Cloudlet Alliance Org  region=${region}  cloudlet_name=${cloudlet_name5}  operator_org_name=packet  alliance_org_name=dmuus

    ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

    Verify AppInst  ${appfqdns[0]}  ${dmuus_appinst_3}  ${origin}
    Verify AppInst  ${appfqdns[1]}  ${dmuus_appinst_5}  ${origin}
    Verify AppInst  ${appfqdns[2]}  ${dmuus_appinst_1}  ${origin}
    Verify AppInst  ${appfqdns[3]}  ${dmuus_appinst_2}  ${origin}

    Length Should Be   ${appfqdns}  4

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${cloudlet_name_3}=  Catenate  SEPARATOR=  ${cloudlet_name_3}  ${epoch}
    ${cloudlet_name_4}=  Catenate  SEPARATOR=  ${cloudlet_name_4}  ${epoch}
    ${cloudlet_name_5}=  Catenate  SEPARATOR=  ${cloudlet_name_5}  ${epoch}

    ${allianceorgs}=  Create List  dmuus

    Create Flavor  region=${region}

    Create App  region=${region}  developer_org_name=${developer_org_name_automation}  access_ports=tcp:1  #permits_platform_apps=${True}

    Set Suite Variable  ${cloudlet_name_3}
    Set Suite Variable  ${cloudlet_name_4}
    Set Suite Variable  ${cloudlet_name_5}

Verify AppInst
    [Arguments]  ${appfqdn}  ${appinst}  ${origin}  

    @{dest}=    Create List  ${appfqdn.gps_location.latitude}  ${appfqdn.gps_location.longitude}

    ${distance}=  Calculate Distance  ${origin}  ${dest}
    ${distance_round}=  Convert To Number  ${distance}  1
    ${appfqdns_distance_round}=  Convert To Number  ${appfqdn.distance}  1

    Should Be Equal             ${appfqdn.carrier_name}                             ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
    Should Be Equal             ${appfqdn.cloudlet_name}                            ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
    Should Be Equal             ${appfqdn.gps_location.latitude}                    ${appinst['data']['cloudlet_loc']['latitude']}
    Should Be Equal             ${appfqdn.gps_location.longitude}                   ${appinst['data']['cloudlet_loc']['longitude']}
    Should Be True              ${appfqdns_distance_round} == (${distance_round} + 0)
    Should Be Equal             ${appfqdn.appinstances[0].app_name}                 ${appinst['data']['key']['app_key']['name']}
    Should Be Equal             ${appfqdn.appinstances[0].app_vers}                 ${appinst['data']['key']['app_key']['version']}
    Should Be Equal             ${appfqdn.appinstances[0].fqdn}                    ${appinst['data']['uri']}
    Should Be Equal             ${appfqdn.appinstances[0].ports[0].proto}          ${appinst['data']['mapped_ports'][0]['proto']}
    Should Be Equal             ${appfqdn.appinstances[0].ports[0].internal_port}  ${appinst['data']['mapped_ports'][0]['internal_port']}
    Should Be Equal             ${appfqdn.appinstances[0].ports[0].public_port}    ${appinst['data']['mapped_ports'][0]['public_port']}
    ${decoded_edge_cookie}=  Decode Cookie  ${appfqdn.appinstances[0].edge_events_cookie}
    Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${mobile_latitude}
    Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${mobile_longitude}
    Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
    Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
    Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${appinst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
    Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${appinst['data']['key']['cluster_inst_key']['cluster_key']['name']}
    Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${appinst['data']['key']['cluster_inst_key']['organization']}

