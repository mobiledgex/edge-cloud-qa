*** Settings ***
Documentation   MasterController Show Nodes

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
	
*** Variables ***

*** Test Cases ***
# ECQ-1476
MC - User shall be able to show nodes 
    [Documentation]
    ...  - run ShowNode on system
    ...  - verify info is correct

   Login  username=${admin_manager_username}  password=${admin_manager_password}

   ${nodes}=  Show Nodes  region=US

   Controller Should Exist  ${nodes}
   DME Should Exist  ${nodes}
   AutoProv Should Exist  ${nodes}
   ClusterSvc Should Exist  ${nodes}
   Shepherd Should Exist  ${nodes}
   CRM Should Exist  ${nodes}

*** Keywords ***
Verify Common Data
   [Arguments]  ${node}

   log to console  ${node}

   Should Match Regexp  ${node['data']['build_date']}  ^\\D{3} \\D{3}
   Should Be Equal      ${node['data']['key']['region']}  US
   Should Match Regexp  ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal      ${node['data']['build_head']}  ${node['data']['build_master']}
   #Should Be Equal As Numbers      ${node['data']['notify_id']}  1
   ${notifyid}=  Run Keyword  Evaluate  type(${node['data']['notify_id']}) == int
   log to console  ${notifyid}
   Should Be True  ${notifyid}

Controller Should Exist
   [Arguments]   ${nodes}

   ${num_found}=  Set Variable  ${0}

   # {'data': {'build_date': 'Tue Feb  9 04:00:38 UTC 2021',
   #        'build_head': 'v1.2.4-hf1-48-g327d5c21',
   #        'build_master': 'v1.2.4-hf1-48-g327d5c21',
   #        'container_version': '2021-02-09',
   #        'hostname': 'controller-54b5ff6c6d-rpxg2',
   #        'internal_pki': 'useVaultCAs,useVaultCerts',
   #        'key': {'cloudlet_key': {},
   #                'name': 'controller-54b5ff6c6d-rpxg2@10.244.7.127:55001',
   #                'region': 'US',
   #                'type': 'controller'},
   #        'notify_id': 1,
   #        'properties': {'PlatformBuildDate': 'Tue Feb  9 04:03:19 UTC 2021',
   #                       'PlatformBuildHead': 'v1.2.4-83-g7cbc43ff+',
   #                       'PlatformBuildMaster': ''}}},

   ${found_properties}=  Set Variable  0
   ${num_properties}=  Set Variable  0
   FOR  ${node}  IN  @{nodes}
      ${num_found}=  Run Keyword If  "${node['data']['key']['type']}" == 'controller'  Set Variable  ${num_found+1}
      ...  ELSE  Set Variable  ${num_found}

      ${found_properties}=  Run Keyword If  "${node['data']['key']['type']}" == 'controller'  Verify Controller  ${node}
      ...  ELSE  Set Variable  ${found_properties}
      ${num_properties}=  Evaluate  ${num_properties}+1
   END 
   Should Be True  ${num_properties} > 0
   Run keyword if  ${num_found}!=${2}  fail  Controllers Not Found

Verify Controller
   [Arguments]  ${node}
   log to console  ${node}

   Verify Common Data  ${node}
   
   ${found_properties}=  Set Variable  0

   Should Be Empty  ${node['data']['key']['cloudlet_key']}
   Should Match Regexp  ${node['data']['key']['name']}  ^${node['data']['hostname']}.+\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
   Should Match Regexp  ${node['data']['container_version']}  ^\\d{4}-\\d{2}-\\d{2}$
   Should Match Regexp  ${node['data']['hostname']}  ^controller-.+

   Run Keyword If  'properties' in ${node['data']}  Should Match Regexp  ${node['data']['properties']['PlatformBuildDate']}  ^\\D{3} \\D{3}
   Run Keyword If  'properties' in ${node['data']}  Should Match Regexp  ${node['data']['properties']['PlatformBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.+
   Run Keyword If  'properties' in ${node['data']}  Should Be Equal  ${node['data']['properties']['PlatformBuildHead']}  ${node['data']['properties']['PlatformBuildMaster']}
   ${found_properties}=  Run Keyword If  'properties' in ${node['data']}  Set Variable  1
   ...  ELSE  Set Variable  ${found_properties}

   Should Be Equal      ${node['data']['internal_pki']}  UseVaultPki   #useVaultCAs,useVaultCerts

   [Return]  ${found_properties}

DME Should Exist
   [Arguments]  ${nodes}

    #{'data': {'build_date': 'Tue Feb  9 04:00:38 UTC 2021',
    #          'build_head': 'v1.2.4-hf1-48-g327d5c21',
    #          'build_master': 'v1.2.4-hf1-48-g327d5c21',
    #          'hostname': 'dme-ffdfdcc55-42wdn',
    #          'internal_pki': 'useVaultCAs,useVaultCerts',
    #          'key': {'cloudlet_key': {'name': 'mexplat-qa-cloudlet',
    #                                   'organization': 'TDG'},
    #                  'name': 'dme-ffdfdcc55-42wdn',
    #                  'region': 'US',
    #                  'type': 'dme'},
    #          'notify_id': 1,
    #          'properties': {'EdgeEventsBuildDate': 'Tue Feb  9 04:03:19 UTC 2021',
    #                         'EdgeEventsBuildHead': 'v1.2.4-83-g7cbc43ff+',
    #                         'EdgeEventsBuildMaster': '',
    #                         'TDGOperatorBuildDate': 'Tue Feb  9 04:03:19 UTC 2021',
    #                         'TDGOperatorBuildHead': 'v1.2.4-83-g7cbc43ff+',
    #                         'TDGOperatorBuildMaster': ''}}},

   ${num_found}=  Set Variable  ${0}

   FOR  ${node}  IN  @{nodes}
      ${num_found}=  Run Keyword If  "${node['data']['key']['type']}" == 'dme'  Set Variable  ${num_found+1}
      ...  ELSE  Set Variable  ${num_found}

      Run Keyword If  "${node['data']['key']['type']}" == 'dme'  Verify DME  ${node}
   END

   Run keyword if  ${num_found}!=${1}  fail  DMEs Not Found

Verify DME 
   [Arguments]  ${node}
   log to console  ${node}

   Verify Common Data  ${node}

   Should Be Equal   ${node['data']['key']['cloudlet_key']['name']}  mexplat-qa-cloudlet
   Should Be Equal   ${node['data']['key']['cloudlet_key']['organization']}  TDG
   Should Be Equal   ${node['data']['key']['name']}  ${node['data']['hostname']}

   Should Match Regexp  ${node['data']['hostname']}  ^dme-.+
   Should Match Regexp  ${node['data']['properties']['EdgeEventsBuildDate']}  ^\\b\\w{3}\\b \\b\\w{3}\\b
   Should Match Regexp  ${node['data']['properties']['EdgeEventsBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.+
   Should Be Equal  ${node['data']['properties']['EdgeEventsBuildHead']}  ${node['data']['properties']['EdgeEventsBuildMaster']}
   Should Match Regexp  ${node['data']['properties']['TDGOperatorBuildDate']}  ^\\b\\w{3}\\b \\b\\w{3}\\b
   Should Match Regexp  ${node['data']['properties']['TDGOperatorBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.+ 
   Should Be Equal  ${node['data']['properties']['TDGOperatorBuildHead']}  ${node['data']['properties']['TDGOperatorBuildMaster']}
   Should Be Equal      ${node['data']['internal_pki']}  UseVaultPki  #useVaultCAs,useVaultCerts

AutoProv Should Exist
   [Arguments]  ${nodes}

   # {'data': {'build_date': 'Tue Feb  9 04:00:38 UTC 2021',
   #        'build_head': 'v1.2.4-hf1-48-g327d5c21',
   #        'build_master': 'v1.2.4-hf1-48-g327d5c21',
   #        'hostname': 'autoprov-d88c49b97-7fhvc',
   #        'internal_pki': 'useVaultCAs,useVaultCerts',
   #        'key': {'cloudlet_key': {},
   #                'name': 'autoprov-d88c49b97-7fhvc',
   #                'region': 'US',
   #                'type': 'autoprov'},
   #        'notify_id': 1,
   #        'properties': {'InfraBuildDate': 'Tue Feb  9 04:03:19 UTC 2021',
   #                       'InfraBuildHead': 'v1.2.4-83-g7cbc43ff+',
   #                       'InfraBuildMaster': ''}}},

   ${num_found}=  Set Variable  ${0}

   FOR  ${node}  IN  @{nodes}
      ${num_found}=  Run Keyword If  "${node['data']['key']['type']}" == 'autoprov'  Set Variable  ${num_found+1}
      ...  ELSE  Set Variable  ${num_found}

      Run Keyword If  "${node['data']['key']['type']}" == 'autoprov'  Verify AutoProv  ${node}
   END

   Run keyword if  ${num_found}!=${1}  fail  AutoProv Not Found

Verify AutoProv
   [Arguments]  ${node}
   log to console  ${node}

   Verify Common Data  ${node}

   Should Be Empty  ${node['data']['key']['cloudlet_key']}
   Should Be Equal   ${node['data']['key']['name']}  ${node['data']['hostname']}

   Should Match Regexp  ${node['data']['hostname']}  ^autoprov-.+
   Should Match Regexp  ${node['data']['properties']['InfraBuildDate']}  ^\\b\\w{3}\\b \\b\\w{3}\\b
   Should Match Regexp  ${node['data']['properties']['InfraBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.+
   Should Be Equal  ${node['data']['properties']['InfraBuildHead']}  ${node['data']['properties']['InfraBuildMaster']}
   Should Be Equal      ${node['data']['internal_pki']}  UseVaultPki    #useVaultCAs,useVaultCerts

ClusterSvc Should Exist
   [Arguments]  ${nodes}

   #  {'data': {'build_date': 'Tue Feb  9 04:00:38 UTC 2021',
   #        'build_head': 'v1.2.4-hf1-48-g327d5c21',
   #        'build_master': 'v1.2.4-hf1-48-g327d5c21',
   #        'hostname': 'cluster-svc-784ff9978-d78nx',
   #        'internal_pki': 'useVaultCAs,useVaultCerts',
   #        'key': {'cloudlet_key': {},
   #                'name': 'cluster-svc-784ff9978-d78nx',
   #                'region': 'US',
   #                'type': 'cluster-svc'},
   #        'notify_id': 1,
   #        'properties': {'InfraClusterSvcBuildDate': 'Tue Feb  9 04:03:19 UTC 2021',
   #                       'InfraClusterSvcBuildHead': 'v1.2.4-83-g7cbc43ff+',
   #                       'InfraClusterSvcBuildMaster': ''}}},

   ${num_found}=  Set Variable  ${0}

   FOR  ${node}  IN  @{nodes}
      ${num_found}=  Run Keyword If  "${node['data']['key']['type']}" == 'cluster-svc'  Set Variable  ${num_found+1}
      ...  ELSE  Set Variable  ${num_found}

      Run Keyword If  "${node['data']['key']['type']}" == 'cluster-svc'  Verify ClusterSvc  ${node}
   END

   Run keyword if  ${num_found}!=${1}  fail  ClusterSvc Not Found

Verify ClusterSvc 
   [Arguments]  ${node}
   log to console  ${node}

   Verify Common Data  ${node}

   Should Be Empty  ${node['data']['key']['cloudlet_key']}
   Should Be Equal   ${node['data']['key']['name']}  ${node['data']['hostname']}

   Should Match Regexp  ${node['data']['hostname']}  ^cluster-svc-.+
   Should Match Regexp  ${node['data']['properties']['InfraClusterSvcBuildDate']}  ^\\b\\w{3}\\b \\b\\w{3}\\b
   Should Match Regexp  ${node['data']['properties']['InfraClusterSvcBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.+
   Should Be Equal  ${node['data']['properties']['InfraClusterSvcBuildHead']}  ${node['data']['properties']['InfraClusterSvcBuildMaster']}

   Should Be Equal      ${node['data']['internal_pki']}  UseVaultPki    #useVaultCAs,useVaultCerts

Shepherd Should Exist
   [Arguments]  ${nodes}

   #   {'data': {'build_date': 'Tue Feb  9 04:00:38 UTC 2021',
   #        'build_head': 'v1.2.4-hf1-48-g327d5c21',
   #        'build_master': 'v1.2.4-hf1-48-g327d5c21',
   #        'hostname': 'packet-qaregression-packet-pf',
   #        'internal_pki': 'useAccessKey,useVaultCAs,useVaultCerts',
   #        'key': {'cloudlet_key': {'name': 'packet-qaregression',
   #                                 'organization': 'packet'},
   #                'name': 'packet-qaregression-packet-pf',
   #                'region': 'US',
   #                'type': 'shepherd'},
   #        'notify_id': 1,
   #        'properties': {'InfraBuildDate': 'Tue Feb  9 04:03:19 UTC 2021',
   #                       'InfraBuildHead': 'v1.2.4-83-g7cbc43ff+',
   #                       'InfraBuildMaster': ''}}}, 

   ${num_found}=  Set Variable  ${0}

   FOR  ${node}  IN  @{nodes}
      ${num_found}=  Run Keyword If  "${node['data']['key']['type']}" == 'shepherd'  Set Variable  ${num_found+1}
      ...  ELSE  Set Variable  ${num_found}

      Run Keyword If  "${node['data']['key']['type']}" == 'shepherd'  Verify Shepherd  ${node}
   END

   Run keyword if  ${num_found}<${1}  fail  Shepherd Not Found

Verify Shepherd
   [Arguments]  ${node}
   log to console  ${node}

   Verify Common Data  ${node}

   Should Be True  len("${node['data']['key']['cloudlet_key']['name']}") > 0
   Should Be True  len("${node['data']['key']['cloudlet_key']['organization']}") > 0

   Should Be Equal   ${node['data']['key']['name']}  ${node['data']['hostname']}

   Should Be True  len("${node['data']['key']['cloudlet_key']['name']}") > 0
   Should Match Regexp  ${node['data']['properties']['InfraBuildDate']}  ^\\b\\w{3}\\b \\b\\w{3}\\b
   Should Match Regexp  ${node['data']['properties']['InfraBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal  ${node['data']['properties']['InfraBuildHead']}  ${node['data']['properties']['InfraBuildMaster']}

   Should Be Equal      ${node['data']['internal_pki']}  useAccessKey,UseVaultPki    #useAccessKey,useVaultCAs,useVaultCerts

CRM Should Exist
   [Arguments]  ${nodes}

   #  {'data': {'build_date': 'Tue Feb  9 04:00:38 UTC 2021',
   #        'build_head': 'v1.2.4-hf1-48-g327d5c21',
   #        'build_master': 'v1.2.4-hf1-48-g327d5c21',
   #        'container_version': '2021-02-09',
   #        'hostname': 'controller-54b5ff6c6d-dtbhf',
   #        'internal_pki': 'useAccessKey,useVaultCAs,useVaultCerts',
   #        'key': {'cloudlet_key': {'name': 'cloudlet1612860729-304284',
   #                                 'organization': 'org1612860729-304284'},
   #                'name': 'controller-54b5ff6c6d-dtbhf',
   #                'region': 'US',
   #                'type': 'crm'},
   #        'notify_id': 1}}, 

   ${num_found}=  Set Variable  ${0}

   FOR  ${node}  IN  @{nodes}
      ${num_found}=  Run Keyword If  "${node['data']['key']['type']}" == 'crm'  Set Variable  ${num_found+1}
      ...  ELSE  Set Variable  ${num_found}

      Run Keyword If  "${node['data']['key']['type']}" == 'crm'  Verify CRM  ${node}
   END

   Run keyword if  ${num_found}<=${0}  fail  CRM Not Found

Verify CRM
   [Arguments]  ${node}
   log to console  ${node}

   Verify Common Data  ${node}

   Should Be True  len("${node['data']['key']['cloudlet_key']['name']}") > 0
   Should Be True  len("${node['data']['key']['cloudlet_key']['organization']}") > 0

   Should Be Equal   ${node['data']['key']['name']}  ${node['data']['hostname']}

   Should Match Regexp  ${node['data']['container_version']}  ^\\d{4}-\\d{2}-\\d{2}$

   Should Be True  len("${node['data']['hostname']}") > 0
   Run Keyword If  not "${node['data']['key']['name']}".startswith('controller')  Should Match Regexp  ${node['data']['properties']['PlatformBuildDate']}  ^\\b\\w{3}\\b \\b\\w{3}\\b
   Run Keyword If  not "${node['data']['key']['name']}".startswith('controller')  Should Match Regexp  ${node['data']['properties']['PlatformBuildHead']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.+
   Run Keyword If  not "${node['data']['key']['name']}".startswith('controller')  Should Be Equal  ${node['data']['properties']['PlatformBuildHead']}  ${node['data']['properties']['PlatformBuildMaster']} 

   Should Be Equal      ${node['data']['internal_pki']}  useAccessKey,UseVaultPki   #useAccessKey,useVaultCAs,useVaultCerts

#Hamburg CRM Should Exist
#   [Arguments]  ${nodes}
#   #{'key': {'name': 'automationHamburgCloudlet', 'node_type': 2, 'cloudlet_key': {'operator_key': {'name': 'TDG'}, 'name': 'automationHamburgCloudlet'}}, 'notify_id': 107, 'build_master': 'v1.0.2-24-g277eca5', 'build_head': 'v1.0.2-24-g277eca5', 'hostname': 'automationHamburgCloudlet'}
#
#   ${found}=  Set Variable  ${False}
#
#   : FOR  ${node}  IN  @{nodes}
#   \  log to console  ${node['data']}
#   \  ${name_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['name']}  automationHamburgCloudlet 
#   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal As Integers    ${node['data']['key']['node_type']}  2
#   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  TDG
#   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  automationHamburgCloudlet
#
#   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}   #\\-\\d{1,3}-\\b
#   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}   #\\-\\d{1,3}-\\b
#
#   \  ${host_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['hostname']}  automationHamburgCloudlet
#
#   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}
#
#   \  Exit For Loop If  ${found}
#
##   \  Log to console  ${node['data']['key']['cloudlet_key']['operator_key']['name']}
#   Run keyword if  ${found}==False  fail  Hamburg CRM Not Found
#
#Azure CRM Should Exist
#   [Arguments]  ${nodes}
#   #{'key': {'name': 'crmazurecentral-76b7d5b66-wh2k7', 'node_type': 2, 'cloudlet_key': {'operator_key': {'name': 'azure'}, 'name': 'automationAzureCentralCloudlet'}}, 'notify_id': 104, 'build_master': 'v1.0.2-24-g277eca5', 'build_head': 'v1.0.2-24-g277eca5', 'hostname': 'crmazurecentral-76b7d5b66-wh2k7'}
#   ${found}=  Set Variable  ${False}
#
#   : FOR  ${node}  IN  @{nodes}
#   \  log to console  ${node['data']}
#   #\  ${name_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['name']}  automationHamburgCloudlet
#   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  ^gitlab-qa 
#
#   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['type']}  crm 
#   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  azure
#   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  automationAzureCentralCloudlet
#
#   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b
#   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b
#
#   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^gitlab-qa
#
#   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}
#
#   \  Exit For Loop If  ${found}
#
#   Run keyword if  ${found}==False  fail  Azure CRM Not Found
#
#GCP CRM Should Exist
#   [Arguments]  ${nodes}
#  #{'key': {'name': 'crmgcpcentral-84f984898d-q54pv', 'node_type': 2, 'cloudlet_key': {'operator_key': {'name': 'gcp'}, 'name': 'automationGcpCentralCloudlet'}}, 'notify_id': 3, 'build_master': 'v1.0.2-24-g277eca5', 'build_head': 'v1.0.2-24-g277eca5', 'hostname': 'crmgcpcentral-84f984898d-q54pv'}
#
#   ${found}=  Set Variable  ${False}
#
#   : FOR  ${node}  IN  @{nodes}
#   \  log to console  ${node['data']}
#   #\  ${name_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['name']}  automationHamburgCloudlet
#   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  ^gitlab-qa
#
#   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['type']}  crm 
#   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  gcp 
#   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  automationGcpCentralCloudlet
#
#   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b
#   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b
#
#   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^gitlab-qa
#
#   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}
#
#   \  Exit For Loop If  ${found}
#
#   Run keyword if  ${found}==False  fail  GCP CRM Not Found
#
#Controllerx Should Exist
#   [Arguments]   ${nodes}
#   #{"data":{"key":{"name":"10.12.0.90:55001","node_type":3,"cloudlet_key":{"operator_key":{}}},"build_master":"v1.0.2-24-g277eca5","build_head":"v1.0.2-24-g277eca5","hostname":"controller-f8459444c-k6j2j"}}
#
#   ${found}=  Set Variable  ${False}
# 
#   : FOR  ${node}  IN  @{nodes}
#   \  log to console  andy
##${check1}=    Run Keyword And Return Status    Should Be Equal As Strings    ${accountNumChk}    6
##Run Keyword If     not ${check1}    Should Be Equal As Strings    ${accountNumChk}    7
#   \  log to console  ${node['data']}
#   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
#   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal As Integers    ${node['data']['key']['node_type']}  3
#   \  ${op_len}=  Get Length  ${node['data']['key']['cloudlet_key']['operator_key']}
#   \  ${len_match}=  Run Keyword And Return Status  Should Be Equal As Integers     ${op_len}  0
#   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
##   \  ${build_head}=  Catenate  SEPARATOR=  ${nodes[0]['data']['build_master']}  +
#
##   \  ${head_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['build_head']}  ${build_head}
#   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#
#   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^controller-
#
#   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${len_match} and ${master_match} and ${head_match} and ${host_match}
#   #Run Keyword  Should Be True  ${name_match} and ${type_match} and ${len_match} and ${master_match} and ${head_match} and ${host_match}
#
#   \  Exit For Loop If  ${found}
#
#   \  Log to console  ${found}
#   Run keyword if  ${found}==False  fail  Controller Not Found 
#   #[return]  ${found}
#
#Get Number Of CRMs
#   [Arguments]   ${nodes}
#   #{"data":{"key":{"name":"10.12.0.90:55001","node_type":3,"cloudlet_key":{"operator_key":{}}},"build_master":"v1.0.2-24-g277eca5","build_head":"v1.0.2-24-g277eca5","hostname":"controller-f8459444c-k6j2j"}}
#
#   ${count}=  Set Variable  0 
#   
#   : FOR  ${node}  IN  @{nodes}
#   \  Log to console  andy
#   \  Log to console  ${count}
#   \  Log to console  andy2
##   \  ${count}=  Evaluate  ${count} + 1
#   \  ${count}=  Run Keyword If  "${node['data']['key']['type']}" == "crm"   Evaluate  ${count}+1  ELSE  Set Variable  ${count}
#
#   [Return]  ${count}
