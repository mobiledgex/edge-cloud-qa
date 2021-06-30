*** Settings ***
Documentation   CreateAppInst TLS

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${cloudlet_name_2}  tmocloud-2
${mobile_latitude}  1
${mobile_longitude}  1

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

${region}=  US 

*** Test Cases ***
# ECQ-2235
CreateAppInst - User shall be able to add TLS and non-TLS ports with cluster=k8s/shared and app=k8s/lb
   [Documentation]
   ...  deploy k8s/shared clusterinst
   ...  deploy k8s/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:999,tcp:2016:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
   ${version}=  Set Variable  ${appInst['data']['key']['app_key']['version']}
   ${version}=  Remove String  ${version}  .

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2015 
   Should Be True               ${appInst['data']['mapped_ports'][0]['public_port']} > 0  
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['fqdn_prefix']}    ${app_default}${version}-tcp- 
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999 
   Should Be True               ${appInst['data']['mapped_ports'][1]['public_port']} > 0 
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][1]['fqdn_prefix']}    ${app_default}${version}-tcp-
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
   Should Be True               ${appInst['data']['mapped_ports'][2]['public_port']} > 0 
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['fqdn_prefix']}    ${app_default}${version}-tcp- 
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8085 
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8085 
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1  #LProtoTCP  
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['fqdn_prefix']}    ${app_default}${version}-tcp-
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
   Should Be True               ${appInst['data']['mapped_ports'][4]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
   Should Be Equal              ${appInst['data']['mapped_ports'][4]['fqdn_prefix']}    ${app_default}${version}-udp-
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls 

   Length Should Be   ${appInst['data']['mapped_ports']}  5

# ECQ-2236
CreateAppInst - User shall be able to add TLS and non-TLS ports with cluster=k8s/dedicated and app=k8s/lb
   [Documentation]
   ...  deploy k8s/dedicated clusterinst
   ...  deploy k8s/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2000-2002:tls,tcp:999,tcp:2016:tls,tcp:8086:tls,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
   ${version}=  Set Variable  ${appInst['data']['key']['app_key']['version']}
   ${version}=  Remove String  ${version}  .

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['end_port']}       2002
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['public_port']}    2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['fqdn_prefix']}    ${app_default}${version}-tcp-
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['public_port']}    999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][1]['fqdn_prefix']}    ${app_default}${version}-tcp-
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['fqdn_prefix']}    ${app_default}${version}-tcp-
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['fqdn_prefix']}    ${app_default}${version}-tcp- 
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
   Should Be Equal              ${appInst['data']['mapped_ports'][4]['fqdn_prefix']}    ${app_default}${version}-udp-
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls

   Length Should Be   ${appInst['data']['mapped_ports']}  5

# ECQ-2237
CreateAppInst - User shall be able to add TLS and non-TLS ports with cluster=docker/dedicated and app=docker/lb
   [Documentation]
   ...  deploy docker/dedicated clusterinst
   ...  deploy docker/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2000-2002:tls,tcp:999,tcp:2016:tls,tcp:8086:tls,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['end_port']}       2002
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['public_port']}    2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['public_port']}    999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls

   Length Should Be   ${appInst['data']['mapped_ports']}  5

# direct not supported
# ECQ-2238
#CreateAppInst - User shall be able to add non TLS ports with cluster=docker/dedicated and app=docker/direct
#   [Documentation]
#   ...  deploy docker/dedicated clusterinst
#   ...  deploy docker/direct app with TLS and non-TLS port
#   ...  verify tls ports are marked tls
#
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated
#
#   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2000-2002,tcp:999,tcp:2016,tcp:8086,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
#
#   ${app_default}=  Get Default App Name
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['end_port']}       2002
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2000
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['public_port']}    2000
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  tls
#   #Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['public_port']}    999
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['public_port']}    2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  tls
#   #Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8086
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8086
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  tls
#   #Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['public_port']}    2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls
#
#   Length Should Be   ${appInst['data']['mapped_ports']}  5

# ECQ-2239
CreateAppInst - User shall be able to add TLS and non-TLS ports with cluster=docker/shared and app=docker/lb
   [Documentation]
   ...  deploy docker/shared clusterinst
   ...  deploy docker/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2000,tcp:2002:tls,tcp:999,tcp:2016:tls,tcp:8086:tls,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['public_port']}    2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  tls
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  2002
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['public_port']}    2002
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][1]['tls']}            ${True}
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['public_port']}    999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['public_port']}    8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          1
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][4]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][5]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][5]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][5]['proto']}          2
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][5]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][5]}  tls

   Length Should Be   ${appInst['data']['mapped_ports']}  6

# direct not supported
# ECQ-2240
#CreateAppInst - User shall be able to add TLS and non-TLS ports with app=vm/direct
#   [Documentation]
#   ...  deploy vm/direct app with TLS and non-TLS port
#   ...  verify tls ports are marked tls
#
#   Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=tcp:2000-2002:tls,tcp:999,tcp:2016:tls,tcp:8086:tls,udp:2016  image_type=ImageTypeQcow  deployment=vm  access_type=direct
#   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
#
#   ${app_default}=  Get Default App Name
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['end_port']}  2002
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2000
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['public_port']}    2000
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
#   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['public_port']}    999
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['public_port']}    2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
#   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8086
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8086
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  fqdn_prefix
#   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}
#
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['public_port']}    2016
#   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
#   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls
#
#   Length Should Be   ${appInst['data']['mapped_ports']}  5

# ECQ-2241
CreateAppInst - User shall be able to add TLS and non-TLS ports with app=vm/lb
   [Documentation]
   ...  deploy vm/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create App  region=${region}  image_path=${qcow_centos_image}  access_ports=tcp:2000-2002:tls,tcp:999,tcp:2016:tls,tcp:8086:tls,udp:2016  image_type=ImageTypeQcow  deployment=vm  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['end_port']}  2002
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['public_port']}    2000
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['public_port']}    999
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8086
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['public_port']}    2016
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls

   Length Should Be   ${appInst['data']['mapped_ports']}  5

# ECQ-2242
CreateAppInst - User shall be able to add TLS and non-TLS ports with cluster=k8s/shared and app=helm/lb
   [Documentation]
   ...  deploy k8s/shared clusterinst
   ...  deploy helm/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:999,tcp:2016:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2015
   Should Be True               ${appInst['data']['mapped_ports'][0]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
   Should Be True               ${appInst['data']['mapped_ports'][1]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
   Should Be True               ${appInst['data']['mapped_ports'][2]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8085
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8085
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][3]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
   Should Be True               ${appInst['data']['mapped_ports'][4]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls

   Length Should Be   ${appInst['data']['mapped_ports']}  5

# ECQ-2243
CreateAppInst - User shall be able to add TLS and non-TLS ports with cluster=k8s/dedicated and app=helm/lb
   [Documentation]
   ...  deploy k8s/dedicated clusterinst
   ...  deploy helm/lb app with TLS and non-TLS port
   ...  verify tls ports are marked tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:999,tcp:2016:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeHelm  deployment=helm  access_type=loadbalancer
   ${appInst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   ${app_default}=  Get Default App Name

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['internal_port']}  2015
   Should Be True               ${appInst['data']['mapped_ports'][0]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][0]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][0]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][0]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['internal_port']}  999
   Should Be True               ${appInst['data']['mapped_ports'][1]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][1]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][1]}  tls

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['internal_port']}  2016
   Should Be True               ${appInst['data']['mapped_ports'][2]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][2]['proto']}          1  #LProtoTCP
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][2]}  fqdn_prefix
   Should Be Equal              ${appInst['data']['mapped_ports'][2]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['internal_port']}  8085
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['public_port']}    8085
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][3]['proto']}          1
   Should Be Equal              ${appInst['data']['mapped_ports'][3]['tls']}            ${True}

   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['internal_port']}  2016
   Should Be True               ${appInst['data']['mapped_ports'][4]['public_port']} > 0
   Should Be Equal As Integers  ${appInst['data']['mapped_ports'][4]['proto']}          2
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  fqdn_prefix
   Dictionary Should Not Contain Key   ${appInst['data']['mapped_ports'][4]}  tls

   Length Should Be   ${appInst['data']['mapped_ports']}  5

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${epoch_time}=  Get Time  epoch

    Set Suite Variable  ${epoch_time}
