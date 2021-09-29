*** Settings ***
Documentation   FindCloudlet with alliance orgs

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  String

Test Setup     Setup
Test Teardown  Cleanup provisioning

*** Variables ***
${app_name}  someapplication   #has to match crm process startup parms
${region}  US
#${code}  2561
${developer_name}  AcmeAppCo
${app_version}  1.0
${access_ports}    tcp:80,tcp:443,udp:10002
${operator_name}   dmuus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91
${cloudlet_name2}  tmocloud-2
${cloudlet_lat2}   35
${cloudlet_long2}  -95
${cloudlet_lat3}   45
${cloudlet_long3}  -95

*** Test Cases ***
# ECQ-3975
FindCloudlet - request shall return cloudlet without allianceorg
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with dmuus alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send findCloudlet with dmuus and coord closer to dmuus
    ...  - verify dmuus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}  alliance_org_list=${allianceorgs}

    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster  #developer_name=MobiledgeX
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster  #developer_name=MobiledgeX

    log to console  ${appinst_1}
    Register Client  #developer_name=MobiledgeX
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=32  longitude=-91

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

# ECQ-3976
FindCloudlet - request shall return cloudlet with allianceorg
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with dmuus alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify packet appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}  alliance_org_list=${allianceorgs}

    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster  #developer_name=MobiledgeX
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster  #developer_name=MobiledgeX

    log to console  ${appinst_1}
    Register Client  #developer_name=MobiledgeX
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-94

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}

    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

# ECQ-3977
FindCloudlet - request shall return updated cloudlet without allianceorg
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with no alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - UpdateCloudlet packet with dmuus alliance org
    ...  - send findCloudlet with dmuus and coord closer to dmuus
    ...  - verify dmuus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2} 

    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster  #developer_name=MobiledgeX
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster  #developer_name=MobiledgeX

    Update Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_list=${allianceorgs}  use_defaults=${False}  token=${super_token}

    Register Client  #developer_name=MobiledgeX
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=31  longitude=-91

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

# ECQ-3978
FindCloudlet - request shall return updated cloudlet with allianceorg
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with no alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify dmuus appinst is returned
    ...  - UpdateCloudlet packet with dmuus alliance org
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify packet appinst is returned
    ...  - UpdateCloudlet packet and remove alliance org
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify dmuus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}
    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster 
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-95
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    Update Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_list=${allianceorgs}  use_defaults=${False}  token=${super_token}

    Register Client  
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-95
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    ${allianceorgs}=  Create List
    Update Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_list=${allianceorgs}  use_defaults=${False}  token=${super_token}

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-95
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

# ECQ-3979
FindCloudlet - request shall return cloudlet with addallianceorg allianceorg
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with no alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify dmuus appinst is returned
    ...  - AddAllianceOrg on packet with dmuus alliance org
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify packet appinst is returned
    ...  - RemoveAllianceOrg on packet and remove alliance org
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify dmuus appinst is returned

    [Tags]  AllianceOrg

    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}
    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-95
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    ${allianceorgs}=  Create List  dmuus
    Add Cloudlet Alliance Org  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_name=dmuus

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-95
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    Remove Cloudlet Alliance Org  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_name=dmuus

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-95
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}

# ECQ-3980
FindCloudlet - request shall return cloudlet with allianceorg on both cloudlets
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with dmuus alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send findCloudlet with dmuus and coord closer to packet
    ...  - verify packet appinst is returned
    ...  - send findCloudlet with packet and coord closer to dmuus
    ...  - verify dmuus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs_dmuus}=  Create List  dmuus
    ${allianceorgs_packet}=  Create List  packet
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}  alliance_org_list=${allianceorgs_packet}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}  alliance_org_list=${allianceorgs_dmuus}

    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster  #developer_name=MobiledgeX
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster  #developer_name=MobiledgeX

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-94
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=packet  latitude=31  longitude=-91
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_1['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat1}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long1}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

# ECQ-3981
FindCloudlet - request shall return cloudlet with multiple allianceorg
    [Documentation]
    ...  - CreateCloudlet dmuus with no alliance org
    ...  - CreateCloudlet packet with multiple alliance org
    ...  - CreateAppinst on 4 cloudlets
    ...  - send findCloudlet with dmuus and coord closer to packet and verify packet appinst is returned
    ...  - send findCloudlet with att and coord closer to packet and verify packet appinst is returned
    ...  - send findCloudlet with GDDT and coord closer to packet and verify packet appinst is returned
    ...  - send findCloudlet with GDDT and coord closer to GDDT and verify GDDT appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  dmuus  att  GDDT
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1} 
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}  alliance_org_list=${allianceorgs}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}gddt  operator_org_name=GDDT  latitude=${cloudlet_lat3}  longitude=${cloudlet_long3}

    ${appinst_1}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}dmuus    operator_org_name=dmuus  cluster_instance_name=autocluster 
    ${appinst_2}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster
    ${appinst_3}=   Create App Instance    region=${region}  cloudlet_name=attcloud-1  operator_org_name=att  cluster_instance_name=autocluster
    ${appinst_4}=   Create App Instance    region=${region}  cloudlet_name=${cloudlet_name}gddt  operator_org_name=GDDT  cluster_instance_name=autocluster

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=35  longitude=-94
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=att  latitude=35  longitude=-91
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=GDDT  latitude=35  longitude=-91
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_2['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat2}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long2}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

    Register Client
    ${cloudlet}=  Find Cloudlet  carrier_name=GDDT  latitude=45  longitude=-91
    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be Equal             ${cloudlet.fqdn}  ${appinst_4['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${cloudlet_lat3}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${cloudlet_long3}
    Verify FindCloudlet  ${cloudlet}  ${appinst_1}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${cloudlet_name}=  Set Variable  cloudlet${epoch}

    ${super_token}=  Get Super Token

    Create Flavor  region=${region}

    Create App      access_ports=${access_ports}  region=${region}  #developer_name=MobiledgeX
    
    Set Suite Variable  ${cloudlet_name}
    Set Suite Variable  ${super_token}

Verify FindCloudlet
  [Arguments]  ${cloudlet}  ${appinst}

    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          1
    Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst['data']['mapped_ports'][0]['internal_port']}
    Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst['data']['mapped_ports'][0]['public_port']}

    Should Be Equal As Numbers  ${cloudlet.ports[1].proto}          1
    Should Be Equal As Numbers  ${cloudlet.ports[1].internal_port}  ${appinst['data']['mapped_ports'][1]['internal_port']}
    Should Be Equal As Numbers  ${cloudlet.ports[1].public_port}    ${appinst['data']['mapped_ports'][1]['public_port']}

    Should Be Equal As Numbers  ${cloudlet.ports[2].proto}          2
    Should Be Equal As Numbers  ${cloudlet.ports[2].internal_port}  ${appinst['data']['mapped_ports'][2]['internal_port']}
    Should Be Equal As Numbers  ${cloudlet.ports[2].public_port}    ${appinst['data']['mapped_ports'][2]['public_port']}

