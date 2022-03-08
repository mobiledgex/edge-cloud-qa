# -*- coding: robot -*-
*** Settings ***
Documentation  Cloudletinfo show resources snapshot platformvms info  
	
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***

${openstack_cloudlet}=  automationBuckhornCloudlet
${openstack_org}=  GDDT
${vcd_cloudlet}=  automationDallasCloudlet
${vcd_org}=  packet
${region}=  US
${mobiledgex_domain}=  mobiledgex.net

*** Test Cases ***
# EC-6249
# ECQ:4409
showCloudletinfo - mcctl shall be able to request resources snapshot status
   [Documentation]
   ...  - send cloudletinfo show for openstack and vcd cloudlet 
   ...  - verify resources snapshot platform vms name
   ...  - verify resources snapshot platform vms type
   ...  - verify resources snapshot platform vms status
   ...  - verify resources snapshot platform vms ipaddresses

   [Template]  Resources Snapshot Via mcctl
        region=${region}  cloudlet=${openstack_cloudlet}  cloudletorg=${openstack_org}
        region=${region}  cloudlet=${vcd_cloudlet}  cloudletorg=${vcd_org}

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   Set Suite Variable  ${super_token}

Resources Snapshot Via mcctl
   [Arguments]  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   ${cloudlet_info}=  Run mcctl  cloudletinfo show ${parmss}

   ${org_parms}=  Set Variable  ${parms['cloudletorg']}
   Set Variable  ${org_parms}
   ${cloudlet_parms}=  Set Variable  ${parms['cloudlet']}
   Set Variable  ${cloudlet_parms}
   ${cloudlet_pf}=  Catenate  SEPARATOR=-  ${cloudlet_parms}  ${org_parms}  pf
   Set Test Variable  ${cloudlet_pf}  
   ${cloudlet_lb}=  Catenate  SEPARATOR=.  ${cloudlet_parms}  ${org_parms}  ${mobiledgex_domain}
   ${cloudlet_lb}=  Convert To Lowercase  ${cloudlet_lb}
   Set Test Variable  ${cloudlet_lb}
   
   Dictionary Should Contain Key  ${cloudlet_info[0]}  resources_snapshot
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['name']}  ${cloudlet_pf}
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['type']}  platform
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['status']}  ACTIVE
   Dictionary Should Contain Key  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['ipaddresses'][0]}   externalIp

   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['name']}  ${cloudlet_lb}
   # Note this field will change to dedicatedrootlb by end of march 2022
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['type']}  rootlb
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['status']}  ACTIVE
   Dictionary Should Contain Key  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['ipaddresses'][0]}   externalIp

#notes: by end of march 2022
#mcctl  --addr https://console-qa.mobiledgex.net cloudletinfo show region=EU cloudlet=eucloud-1|egrep -A 13 resourcessnapshot
#  resourcessnapshot:
#    platformvms:
#    - name: fake-platform-vm
#      type: platform
#      status: ACTIVE
#      infraflavor: x1.small
#      ipaddresses:
#      - externalip: 10.101.100.10
#    - name: fake-rootlb-vm
#      type: rootlb
#      status: ACTIVE
#      infraflavor: x1.small
#      ipaddresses:
#      - externalip: 10.101.100.11
#will now show
#  resourcessnapshot:
#    platformvms:
#    - name: fake-platform-vm
#      type: platform
#      status: ACTIVE
#      infraflavor: x1.small
#      ipaddresses:
#      - externalip: 10.101.100.10
#    - name: fake-rootlb-vm
#      type: dedicatedrootlb
#      status: ACTIVE
#      infraflavor: x1.small
#      ipaddresses:
#      - externalip: 10.101.100.11
