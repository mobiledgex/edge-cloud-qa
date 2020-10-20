*** Settings ***
Documentation   GetAppInstList with cloudlets with same coord

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name_1}  tmocloud-1
${cloudlet_name_2}  tmocloud-2
${cloudlet_name_3}  tmocloud-3
${cloudlet_name_4}  tmocloud-4
${cloudlet_name_5}  tmocloud-5
${cloudlet_name_6}  tmocloud-6
${cloudlet_name_7}  tmocloud-7
${cloudlet_name_8}  tmocloud-8
#${cloudlet_name_9}  tmocloud-9
#${cloudlet_name_10}  tmocloud-10

${gcp_operator_name}  gcp
${gcp_cloudlet_name}  gcpcloud-1  #has to match crm process startup parms

${azure_operator_name}  azure
${azure_cloudlet_name}  azurecloud-1  #has to match crm process startup parms

${gcp_cloudlet_latitude}	  37
${gcp_cloudlet longitude}	  -95
${azure_cloudlet_latitude}	  38
${azure_cloudlet longitude}	  -95

${mobile_latitude}  1
${mobile_longitude}  1

${distance_offset}=  100

${num_found_21}=  ${0}
${num_found_22}=  ${0}
${num_found_31}=  ${0}
${num_found_32}=  ${0}

${num_finds}=  ${60}

*** Test Cases ***
# ECQ-2795
GetAppInstList - request shall return 2 cloudlets with same coord in random order
    [Documentation]
    ...  - registerClient
    ...  - add 2 cloudlets with same coord
    ...  - send GetAppInstList for 10 cloudlets
    ...  - verify returns 10 cloudlets
    ...  - verify the 2 cloudlets with same coord come in different orders

    Register Client

    FOR  ${x}  IN RANGE  0  ${num_finds} 
        ${appfqdns}=  Get App Instance List  carrier_name=${operator_name}  latitude=${mobile_latitude}  longitude=${mobile_longitude}  limit=10

        log to console  ${appfqdns[2].cloudlet_name} ${appfqdns[3].cloudlet_name}

        Should Be True  '${appfqdns[2].cloudlet_name}' == '${tmus_appinst_5.key.cluster_inst_key.cloudlet_key.name}' or '${appfqdns[2].cloudlet_name}' == '${tmus_appinst_6.key.cluster_inst_key.cloudlet_key.name}'
        ${num_found_21}=  Set Variable If  '${appfqdns[2].cloudlet_name}' == '${tmus_appinst_5.key.cluster_inst_key.cloudlet_key.name}'  ${num_found_21+1}  ${num_found_21}
        ${num_found_22}=  Set Variable If  '${appfqdns[2].cloudlet_name}' == '${tmus_appinst_6.key.cluster_inst_key.cloudlet_key.name}'  ${num_found_22+1}  ${num_found_22}

        Should Be True  '${appfqdns[3].cloudlet_name}' == '${tmus_appinst_5.key.cluster_inst_key.cloudlet_key.name}' or '${appfqdns[3].cloudlet_name}' == '${tmus_appinst_6.key.cluster_inst_key.cloudlet_key.name}'
        ${num_found_31}=  Set Variable If  '${appfqdns[3].cloudlet_name}' == '${tmus_appinst_5.key.cluster_inst_key.cloudlet_key.name}'  ${num_found_31+1}  ${num_found_31}
        ${num_found_32}=  Set Variable If  '${appfqdns[3].cloudlet_name}' == '${tmus_appinst_6.key.cluster_inst_key.cloudlet_key.name}'  ${num_found_32+1}  ${num_found_32}


        Should Be Equal  ${appfqdns[9].cloudlet_name}  ${gcp_appinst.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[8].cloudlet_name}  ${azure_appinst.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[6].cloudlet_name}  ${tmus_appinst_1.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[7].cloudlet_name}  ${tmus_appinst_2.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[0].cloudlet_name}  ${tmus_appinst_3.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[1].cloudlet_name}  ${tmus_appinst_4.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[4].cloudlet_name}  ${tmus_appinst_7.key.cluster_inst_key.cloudlet_key.name}
        Should Be Equal  ${appfqdns[5].cloudlet_name}  ${tmus_appinst_8.key.cluster_inst_key.cloudlet_key.name}

        Length Should Be   ${appfqdns}  10
        Length Should Be   ${appfqdns[0].appinstances}  1
        Length Should Be   ${appfqdns[0].appinstances[0].ports}  1

    END

    Should Be True  (${num_found_21}+${num_found_22})/${num_finds}*100 > 35
    Should Be True  (${num_found_22}+${num_found_22})/${num_finds}*100 > 35
    Should Be True  ${num_found_22}+${num_found_21} == ${num_finds}

    Should Be True  (${num_found_31}+${num_found_32})/${num_finds}*100 > 35
    Should Be True  (${num_found_32}+${num_found_32})/${num_finds}*100 > 35
    Should Be True  ${num_found_32}+${num_found_31} == ${num_finds}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${cloudlet_name_3}=  Catenate  SEPARATOR=  ${cloudlet_name_3}  ${epoch}
    ${cloudlet_name_4}=  Catenate  SEPARATOR=  ${cloudlet_name_4}  ${epoch}
    ${cloudlet_name_5}=  Catenate  SEPARATOR=  ${cloudlet_name_5}  ${epoch}
    ${cloudlet_name_6}=  Catenate  SEPARATOR=  ${cloudlet_name_6}  ${epoch}
    ${cloudlet_name_7}=  Catenate  SEPARATOR=  ${cloudlet_name_7}  ${epoch}
    ${cloudlet_name_8}=  Catenate  SEPARATOR=  ${cloudlet_name_8}  ${epoch}
    #${cloudlet_name_9}=  Catenate  SEPARATOR=  ${cloudlet_name_9}  ${epoch}
    #${cloudlet_name_10}=  Catenate  SEPARATOR=  ${cloudlet_name_10}  ${epoch}
    ${gcp_cloudlet_name}=  Catenate  SEPARATOR=  ${gcp_cloudlet_name}  ${epoch}
    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    #Create Developer            
    Create Flavor
    #Create Cluster	
    Create Cloudlet	   cloudlet_name=${cloudlet_name3}  operator_org_name=${operator_name}  latitude=3  longitude=3
    Create Cloudlet        cloudlet_name=${cloudlet_name4}  operator_org_name=${operator_name}  latitude=4  longitude=4
    Create Cloudlet        cloudlet_name=${cloudlet_name5}  operator_org_name=${operator_name}  latitude=5  longitude=5
    Create Cloudlet        cloudlet_name=${cloudlet_name6}  operator_org_name=${operator_name}  latitude=5  longitude=5
    Create Cloudlet        cloudlet_name=${cloudlet_name7}  operator_org_name=${operator_name}  latitude=7  longitude=7
    Create Cloudlet        cloudlet_name=${cloudlet_name8}  operator_org_name=${operator_name}  latitude=8  longitude=8
    #Create Cloudlet        cloudlet_name=${cloudlet_name9}  operator_org_name=${operator_name}  latitude=9  longitude=9
    #Create Cloudlet        cloudlet_name=${cloudlet_name10}  operator_org_name=${operator_name}  latitude=10  longitude=10

    Create Cloudlet        cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  latitude=${gcp_cloudlet_latitude}  longitude=${gcp_cloudlet_longitude}
    Create Cloudlet        cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}

    Create App			access_ports=tcp:1  #permits_platform_apps=${True}
    ${tmus_appinst_1}=           Create App Instance  cloudlet_name=${cloudlet_name_1}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_2}=           Create App Instance  cloudlet_name=${cloudlet_name_2}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_3}=           Create App Instance  cloudlet_name=${cloudlet_name_3}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_4}=           Create App Instance  cloudlet_name=${cloudlet_name_4}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_5}=           Create App Instance  cloudlet_name=${cloudlet_name_5}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_6}=           Create App Instance  cloudlet_name=${cloudlet_name_6}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_7}=           Create App Instance  cloudlet_name=${cloudlet_name_7}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    ${tmus_appinst_8}=           Create App Instance  cloudlet_name=${cloudlet_name_8}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    #${tmus_appinst_9}=           Create App Instance  cloudlet_name=${cloudlet_name_9}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    #${tmus_appinst_10}=           Create App Instance  cloudlet_name=${cloudlet_name_10}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

    ${gcp_appinst}=             Create App Instance         cloudlet_name=${gcp_cloudlet_name}  operator_org_name=${gcp_operator_name}  cluster_instance_name=autocluster
    ${azure_appinst}=           Create App Instance         cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${tmus_appinst_1} 
    Set Suite Variable  ${tmus_appinst_2}
    Set Suite Variable  ${tmus_appinst_3}
    Set Suite Variable  ${tmus_appinst_4}
    Set Suite Variable  ${tmus_appinst_5}
    Set Suite Variable  ${tmus_appinst_6}
    Set Suite Variable  ${tmus_appinst_7}
    Set Suite Variable  ${tmus_appinst_8}
    #Set Suite Variable  ${tmus_appinst_9}
    #Set Suite Variable  ${tmus_appinst_10}

    Set Suite Variable  ${gcp_appinst}
    Set Suite Variable  ${azure_appinst}


