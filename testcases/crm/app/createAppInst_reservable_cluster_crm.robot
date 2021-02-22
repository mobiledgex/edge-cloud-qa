*** Settings ***
Documentation   DeleteIdleReservableClusterInst

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDmeRest         dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  EU
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3213
CreateAppInst - shall be able to create/delete docker reservable clusters on CRM
   [Documentation]
   ...  - create a docker app
   ...  - create an appinst with reservable autocluster and verify the app is reachable
   ...  - delete the app instance and verify the cluster is not deleted
   ...  - create another appinst with reservable autocluster and verify the same cluste is used again
   ...  - delete the app instance and verify the cluster is not deleted
   ...  - delete idle clusters and verify the cluster is deleted 

   [Tags]  ReservableCluster

   Create App  region=${region}   app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:2015,udp:2016
   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}

   Should Match Regexp  ${app_inst1['data']['real_cluster_name']}  reservable[0-9]
   ${uri}=  Convert To Lowercase  ${app_inst1['data']['real_cluster_name']}.${cloudlet_name_crm}.${operator_name_crm}.mobiledgex.net
   Should Be Equal  ${app_inst1['data']['uri']}  ${uri}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   Should Be True  ${cluster_inst1[0]['data']['reservable']} 
   Should Be Equal  ${cluster_inst1[0]['data']['reserved_by']}  ${developer_org_name_automation}
   Should Be True  ${cluster_inst1[0]['data']['reservation_ended_at']['seconds']} > 0
   Should Be True  ${cluster_inst1[0]['data']['reservation_ended_at']['nanos']} > 0

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=1  longitude=1  carrier_name=${operator_name_crm}
   Should Be Equal  ${cloudlet['fqdn']}  ${app_inst1['data']['uri']}
   #${fqdn}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   TCP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][1]['public_port']}

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst11}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst11}  1
   Should Be True  ${cluster_inst11[0]['data']['reservable']}
   Dictionary Should Not Contain Key  ${cluster_inst11[0]['data']}  reserved_by
   Should Be True  ${cluster_inst11[0]['data']['reservation_ended_at']['seconds']} > ${cluster_inst1[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst11[0]['data']['reservation_ended_at']['nanos']} > 0
   Should Be True  ${cluster_inst11[0]['data']['created_at']['seconds']} == ${cluster_inst1[0]['data']['created_at']['seconds']}
   Should Be True  ${cluster_inst11[0]['data']['created_at']['nanos']} == ${cluster_inst1[0]['data']['created_at']['nanos']}

   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}
   Should Be Equal  ${app_inst2['data']['real_cluster_name']}  ${app_inst1['data']['real_cluster_name']}
   Should Be Equal  ${app_inst2['data']['uri']}  ${app_inst1['data']['uri']}

   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   Should Be True  ${cluster_inst2[0]['data']['reservable']}
   Should Be Equal  ${cluster_inst2[0]['data']['reserved_by']}  ${cluster_inst1[0]['data']['reserved_by']}
   Should Be True  ${cluster_inst2[0]['data']['reservation_ended_at']['seconds']} == ${cluster_inst11[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst2[0]['data']['reservation_ended_at']['nanos']} == ${cluster_inst11[0]['data']['reservation_ended_at']['nanos']} 

   Register Client
   ${cloudlet2}=  Find Cloudlet  latitude=1  longitude=1  carrier_name=${operator_name_crm}
   Should Be Equal  ${cloudlet2['fqdn']}  ${app_inst2['data']['uri']}
   #${fqdn2}=  Catenate  SEPARATOR=  ${cloudlet2['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   TCP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet2['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet2['ports'][1]['public_port']}

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst21}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst21}  1
   Should Be True  ${cluster_inst21[0]['data']['reservable']}
   Dictionary Should Not Contain Key  ${cluster_inst11[0]['data']}  reserved_by
   Should Be True  ${cluster_inst21[0]['data']['reservation_ended_at']['seconds']} > ${cluster_inst2[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst21[0]['data']['reservation_ended_at']['nanos']} > 0

   Delete Idle Reservable Cluster Instances  region=${region}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0

# ECQ-3214
CreateAppInst - shall be able to create/delete k8s reservable clusters on CRM
   [Documentation]
   ...  - create a k8s app
   ...  - create an appinst with reservable autocluster and verify the app is reachable
   ...  - delete the app instance and verify the cluster is not deleted
   ...  - create another appinst with reservable autocluster and verify the same cluste is used again
   ...  - delete the app instance and verify the cluster is not deleted
   ...  - delete idle clusters and verify the cluster is deleted

   [Tags]  ReservableCluster

   Create App  region=${region}   app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:2015,udp:2016
   ${app_inst1}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}

   Should Match Regexp  ${app_inst1['data']['real_cluster_name']}  reservable[0-9]
   ${uri}=  Convert To Lowercase  ${cloudlet_name_crm}.${operator_name_crm}.mobiledgex.net
   Should Be Equal  ${app_inst1['data']['uri']}  ${uri}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  1
   Should Be True  ${cluster_inst1[0]['data']['reservable']}
   Should Be Equal  ${cluster_inst1[0]['data']['reserved_by']}  ${developer_org_name_automation}
   Should Be True  ${cluster_inst1[0]['data']['reservation_ended_at']['seconds']} > 0
   Should Be True  ${cluster_inst1[0]['data']['reservation_ended_at']['nanos']} > 0

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=1  longitude=1  carrier_name=${operator_name_crm}
   Should Be Equal  ${cloudlet['fqdn']}  ${app_inst1['data']['uri']}
   #${fqdn}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   TCP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][1]['public_port']}

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst11}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst11}  1
   Should Be True  ${cluster_inst11[0]['data']['reservable']}
   Dictionary Should Not Contain Key  ${cluster_inst11[0]['data']}  reserved_by
   Should Be True  ${cluster_inst11[0]['data']['reservation_ended_at']['seconds']} > ${cluster_inst1[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst11[0]['data']['reservation_ended_at']['nanos']} > 0
   Should Be True  ${cluster_inst11[0]['data']['created_at']['seconds']} == ${cluster_inst1[0]['data']['created_at']['seconds']}
   Should Be True  ${cluster_inst11[0]['data']['created_at']['nanos']} == ${cluster_inst1[0]['data']['created_at']['nanos']}

   ${app_inst2}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  auto_delete=${False}
   Should Be Equal  ${app_inst2['data']['real_cluster_name']}  ${app_inst1['data']['real_cluster_name']}
   Should Be Equal  ${app_inst2['data']['uri']}  ${app_inst1['data']['uri']}

   ${cluster_inst2}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst2}  1
   Should Be True  ${cluster_inst2[0]['data']['reservable']}
   Should Be Equal  ${cluster_inst2[0]['data']['reserved_by']}  ${cluster_inst1[0]['data']['reserved_by']}
   Should Be True  ${cluster_inst2[0]['data']['reservation_ended_at']['seconds']} == ${cluster_inst11[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst2[0]['data']['reservation_ended_at']['nanos']} == ${cluster_inst11[0]['data']['reservation_ended_at']['nanos']}

   Register Client
   ${cloudlet2}=  Find Cloudlet  latitude=1  longitude=1  carrier_name=${operator_name_crm}
   Should Be Equal  ${cloudlet2['fqdn']}  ${app_inst2['data']['uri']}
   #${fqdn2}=  Catenate  SEPARATOR=  ${cloudlet2['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   TCP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet2['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet2['ports'][1]['public_port']}

   Delete App Instance  region=${region}  app_name=${app_name_default}-1  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=autocluster${app_name_default}-1  cluster_instance_developer_org_name=MobiledgeX

   ${cluster_inst21}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst21}  1
   Should Be True  ${cluster_inst21[0]['data']['reservable']}
   Should Be True  ${cluster_inst21[0]['data']['reservable']}
   Dictionary Should Not Contain Key  ${cluster_inst11[0]['data']}  reserved_by
   Should Be True  ${cluster_inst21[0]['data']['reservation_ended_at']['seconds']} > ${cluster_inst2[0]['data']['reservation_ended_at']['seconds']}
   Should Be True  ${cluster_inst21[0]['data']['reservation_ended_at']['nanos']} > 0

   Delete Idle Reservable Cluster Instances  region=${region}

   ${cluster_inst1}=  Show Cluster Instances  region=${region}  cluster_name=${app_inst1['data']['real_cluster_name']}  developer_org_name=MobiledgeX
   Length Should Be  ${cluster_inst1}  0

*** Keywords ***
Setup
   Create Flavor  region=${region}

   ${app_name_default}=  Get Default App Name

   Set Suite Variable  ${app_name_default}

Teardown
   Cleanup Provisioning

