*** Settings ***
Documentation   PlatformFindCloudlet with alliance org

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Setup     Setup
Test Teardown  Cleanup provisioning

*** Variables ***
${azure_operator_name}  azure
${gcp_operator_name}  gcp
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
${app_name}  someapplication2   
${developer_name}  AcmeAppCo
${app_version}  1.0

${azure_cloudlet_latitude}	  37
${azure_cloudlet longitude}	  -95
${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -94
${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

${cloudlet_lat1}   31
${cloudlet_long1}  -91
${cloudlet_lat2}   32
${cloudlet_long2}  -92
#${cloudlet_lat3}   45
#${cloudlet_long3}  -95

${region}=  US

*** Test Cases ***
# ECQ-3982
PlatformFindCloudlet - request shall return cloudlet without allianceorg
    [Documentation]
    ...  - CreateCloudlet tmus with no alliance org
    ...  - CreateCloudlet packet with tmus alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send GetAppOfficialFqdn and PlatformFindCloudlet with tmus and coord closer to tmus
    ...  - verify tmus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  tmus

    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}  alliance_org_list=${allianceorgs}

    ${appinst_1}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus  cluster_instance_name=autocluster
    ${appinst_2}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}

    ${fqdn}=  Get App Official FQDN  latitude=35  longitude=-94
    Should Be Equal  ${fqdn.ports[0].proto}  ${tmus_appinst['data']['mapped_ports'][0]['proto']}
    Should Be Equal  ${fqdn.ports[0].internal_port}  ${tmus_appinst['data']['mapped_ports'][0]['internal_port']}
    Length Should Be  ${fqdn.ports}  1

    ${decoded_client_token}=  Decoded Client Token
    Should Be Equal  ${decoded_client_token['AppKey']['organization']}  ${developer_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['name']}  ${app_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['version']}  ${app_version_default}
    Should Be Equal As Numbers  ${decoded_client_token['Location']['latitude']}  35
    Should Be Equal As Numbers  ${decoded_client_token['Location']['longitude']}  -94

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}	

    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}

    Verify PlatformFindCloudlet  ${cloudlet}  ${tmus_appinst}  ${tmus_cloudlet_latitude}  ${tmus_cloudlet_longitude}

# ECQ-3983
PlatformFindCloudlet - request shall return cloudlet with allianceorg
    [Documentation]
    ...  - CreateCloudlet tmus with no alliance org
    ...  - CreateCloudlet packet with tmus alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send GetAppOfficialFqdn and PlatformFindCloudlet with tmus and coord closer to packet
    ...  - verify packet appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  tmus

    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}  alliance_org_list=${allianceorgs}

    ${appinst_1}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus  cluster_instance_name=autocluster
    ${appinst_2}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}

    ${fqdn}=  Get App Official FQDN  latitude=32  longitude=-94
    Should Be Equal  ${fqdn.ports[0].proto}  ${tmus_appinst['data']['mapped_ports'][0]['proto']}
    Should Be Equal  ${fqdn.ports[0].internal_port}  ${tmus_appinst['data']['mapped_ports'][0]['internal_port']}
    Length Should Be  ${fqdn.ports}  1

    ${decoded_client_token}=  Decoded Client Token
    Should Be Equal  ${decoded_client_token['AppKey']['organization']}  ${developer_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['name']}  ${app_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['version']}  ${app_version_default}
    Should Be Equal As Numbers  ${decoded_client_token['Location']['latitude']}  32
    Should Be Equal As Numbers  ${decoded_client_token['Location']['longitude']}  -94

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}

    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}

    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_2}  ${cloudlet_lat2}  ${cloudlet_long2}

# ECQ-3984
PlatformFindCloudlet - request shall return updated cloudlet with allianceorg
    [Documentation]
    ...  - CreateCloudlet tmus with no alliance org
    ...  - CreateCloudlet packet with no alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send GetAppOfficialFqdn and PlatformFindCloudlet with tmus and coord closer to packet
    ...  - verify tmus appinst is returned
    ...  - UpdateCloudlet packet with tmus alliance org
    ...  - send PlatformFindCloudlet with tmus 
    ...  - verify packet appinst is returned
    ...  - UpdateCloudlet packet and remove alliance org
    ...  - send packetFindCloudlet with tmus and coord closer to packet
    ...  - verify tmus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  tmus

    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}

    ${appinst_1}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus  cluster_instance_name=autocluster
    ${appinst_2}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}

    ${fqdn}=  Get App Official FQDN  latitude=32  longitude=-94
    Should Be Equal  ${fqdn.ports[0].proto}  ${tmus_appinst['data']['mapped_ports'][0]['proto']}
    Should Be Equal  ${fqdn.ports[0].internal_port}  ${tmus_appinst['data']['mapped_ports'][0]['internal_port']}
    Length Should Be  ${fqdn.ports}  1

    ${decoded_client_token}=  Decoded Client Token
    Should Be Equal  ${decoded_client_token['AppKey']['organization']}  ${developer_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['name']}  ${app_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['version']}  ${app_version_default}
    Should Be Equal As Numbers  ${decoded_client_token['Location']['latitude']}  32
    Should Be Equal As Numbers  ${decoded_client_token['Location']['longitude']}  -94

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_1}  ${cloudlet_lat1}  ${cloudlet_long1}

    Update Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_list=${allianceorgs}  use_defaults=${False}  token=${super_token}

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_2}  ${cloudlet_lat2}  ${cloudlet_long2}


    ${allianceorgs}=  Create List
    Update Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_list=${allianceorgs}  use_defaults=${False}  token=${super_token}

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_1}  ${cloudlet_lat1}  ${cloudlet_long1}

# ECQ-3985
PlatformFindCloudlet - request shall return cloudlet with addallianceorg allianceorg
    [Documentation]
    ...  - CreateCloudlet tmus with no alliance org
    ...  - CreateCloudlet packet with no alliance org
    ...  - CreateAppinst on both cloudlets
    ...  - send GetAppOfficialFqdn and PlatformFindCloudlet with tmus and coord closer to packet
    ...  - verify tmus appinst is returned
    ...  - AddAllianceOrg on packet with tmus alliance org
    ...  - send PlatformFindCloudlet with tmus and coord closer to packet
    ...  - verify packet appinst is returned
    ...  - RemoveAllianceOrg on packet and remove alliance org
    ...  - send PlatformFindCloudlet with tmus and coord closer to packet
    ...  - verify tmus appinst is returned

    [Tags]  AllianceOrg

    ${allianceorgs}=  Create List  tmus

    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus    latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    Create Cloudlet  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}

    ${appinst_1}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}tmus    operator_org_name=tmus  cluster_instance_name=autocluster
    ${appinst_2}=   Create App Instance  app_name=${app_name_default}  developer_org_name=${developer_org_name_automation}  region=${region}  cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  cluster_instance_name=autocluster

    Register Client  developer_org_name=${developer_name_default}  app_name=${app_name_default}

    ${fqdn}=  Get App Official FQDN  latitude=32  longitude=-94
    Should Be Equal  ${fqdn.ports[0].proto}  ${tmus_appinst['data']['mapped_ports'][0]['proto']}
    Should Be Equal  ${fqdn.ports[0].internal_port}  ${tmus_appinst['data']['mapped_ports'][0]['internal_port']}
    Length Should Be  ${fqdn.ports}  1

    ${decoded_client_token}=  Decoded Client Token
    Should Be Equal  ${decoded_client_token['AppKey']['organization']}  ${developer_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['name']}  ${app_name_default}
    Should Be Equal  ${decoded_client_token['AppKey']['version']}  ${app_version_default}
    Should Be Equal As Numbers  ${decoded_client_token['Location']['latitude']}  32
    Should Be Equal As Numbers  ${decoded_client_token['Location']['longitude']}  -94

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_1}  ${cloudlet_lat1}  ${cloudlet_long1}

    Add Cloudlet Alliance Org  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_name=tmus

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_2}  ${cloudlet_lat2}  ${cloudlet_long2}

    Remove Cloudlet Alliance Org  region=${region}   cloudlet_name=${cloudlet_name}packet  operator_org_name=packet  alliance_org_name=tmus

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
    ${cloudlet}=  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Verify PlatformFindCloudlet  ${cloudlet}  ${appinst_1}  ${cloudlet_lat1}  ${cloudlet_long1}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}
    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}
    ${cloudlet_name}=  Set Variable  cloudlet${epoch}
    ${super_token}=  Get Super Token

    Create Flavor  region=${region}
    Create Cloudlet  region=${region}  cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude} 
    Create Cloudlet  region=${region}  cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create App  region=${region}  developer_org_name=${developer_org_name_automation}  access_ports=tcp:1  official_fqdn=${samsung_uri}  #permits_platform_apps=${True}
    ${tmus_appinst}=            Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
    Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster
    Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=  Get Default App Name

    Set Suite Variable  ${tmus_appinst}

    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  
    #Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_org_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

    ${app_version_default}=     Get Default App Version
    Set Suite Variable  ${app_version_default}

    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${developer_name_default}
    Set Suite Variable  ${app_name_default}
    Set Suite Variable  ${cloudlet_name}
    Set Suite Variable  ${super_token}

Verify PlatformFindCloudlet
    [Arguments]  ${cloudlet}  ${appinst}  ${latitude}  ${longitude}

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND

    Should Be Equal             ${cloudlet.fqdn}                         ${appinst['data']['uri']}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${latitude}
    Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${longitude}

    Should Be Equal As Numbers  ${cloudlet.ports[0].proto}          ${appinst['data']['mapped_ports'][0]['proto']}  #LProtoTCP
    Should Be Equal As Numbers  ${cloudlet.ports[0].internal_port}  ${appinst['data']['mapped_ports'][0]['internal_port']}
    Should Be Equal As Numbers  ${cloudlet.ports[0].public_port}    ${appinst['data']['mapped_ports'][0]['public_port']}

    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

