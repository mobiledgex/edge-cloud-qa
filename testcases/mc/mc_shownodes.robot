*** Settings ***
Documentation   MasterController user/current superuser

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
	
*** Variables ***

*** Test Cases ***
MC - User shall be able to show nodes 
    [Documentation]
    ...  run ShowNode on system
    ...  verify info is correct

   Login
   ${token}=  Get Token

   ${nodes}=  Show Nodes  region=US
#   log to console  ${nodes}

   ${cloudlets}=  Show Cloudlets  region=US  token=${token}  use_defaults=${False}
   ${num_cloudlets}=  Get Length  ${cloudlets}
   log to console  ${num_cloudlets}

#   Controller Should Exist  ${nodes}
   DME Should Exist  ${nodes}
   #Hamburg CRM Should Exist  ${nodes}
   Azure CRM Should Exist    ${nodes}
   GCP CRM Should Exist      ${nodes}

   ${num_crm_nodes}=  Get Number Of CRMs  ${nodes}
   Log To Console  ${num_crm_nodes}

   Should Be Equal  ${num_crm_nodes}  ${num_cloudlets}

#   : FOR  ${node}  IN  @{nodes}
#   \  log to console  ${node}
#   \  Controller Should Exist

#   ${op_len}=  Get Length  ${nodes[0]['data']['key']['cloudlet_key']['operator_key']}
#   ${build_head}=  Catenate  SEPARATOR=  ${nodes[0]['data']['build_master']}  +
#   Should Match Regexp             ${nodes[0]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
#   Should Be Equal As Integers     ${nodes[0]['data']['key']['node_type']}  3
#   Should Be Equal As Integers     ${op_len}  0
#   Should Match Regexp             ${nodes[0]['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   Should Be Equal                 ${nodes[0]['data']['build_head']}  ${build_head}
#   Should Match Regexp             ${nodes[0]['data']['hostname']}  ^controller-
#
#   ${op_len}=  Get Length  ${nodes[1]['data']['key']['cloudlet_key']['operator_key']}
#   ${build_head}=  Catenate  SEPARATOR=  ${nodes[1]['data']['build_master']}  +
#   Should Match Regexp             ${nodes[1]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
#   Should Be Equal As Integers     ${nodes[1]['data']['key']['node_type']}  3
#   Should Be Equal As Integers     ${op_len}  0
#   Should Match Regexp             ${nodes[1]['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   Should Be Equal                 ${nodes[1]['data']['build_head']}  ${build_head}
#   Should Match Regexp             ${nodes[1]['data']['hostname']}  ^controller-

#   ${op_len}=  Get Length  ${nodes[2]['data']['key']['cloudlet_key']['operator_key']}
#   ${build_head}=  Catenate  SEPARATOR=  ${nodes[2]['data']['build_master']}  +
#   Should Match Regexp             ${nodes[2]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
#   Should Be Equal As Integers     ${nodes[2]['data']['key']['node_type']}  3
#   Should Be Equal As Integers     ${op_len}  0
#   Should Match Regexp             ${nodes[2]['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   Should Be Equal                 ${nodes[2]['data']['build_head']}  ${build_head}
#   Should Match Regexp             ${nodes[2]['data']['hostname']}  ^crmattcloud1-

   #Should Match Regexp  ${nodes[1]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
   #Should Be Equal  ${nodes[0]['data']['key']['name']}  andy

*** Keywords ***
Controller Should Exist
   [Arguments]   ${nodes}
   ${op_len}=  Get Length  ${nodes[0]['data']['key']['cloudlet_key']['operator_key']}
   #${build_head}=  Catenate  SEPARATOR=  ${nodes[0]['data']['build_master']}  +
   Should Match Regexp             ${nodes[0]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
   Should Be Equal As Integers     ${nodes[0]['data']['key']['node_type']}  3
   Should Be Equal As Integers     ${op_len}  0
   Should Match Regexp             ${nodes[0]['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
   #Should Be Equal                 ${nodes[0]['data']['build_head']}  ${build_head}
   Should Match Regexp             ${nodes[0]['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
   Should Match Regexp             ${nodes[0]['data']['hostname']}  ^controller-

#   ${op_len}=  Get Length  ${nodes[1]['data']['key']['cloudlet_key']['operator_key']}
#   #${build_head}=  Catenate  SEPARATOR=  ${nodes[1]['data']['build_master']}  +
#   Should Match Regexp             ${nodes[1]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
#   Should Be Equal As Integers     ${nodes[1]['data']['key']['node_type']}  3
#   Should Be Equal As Integers     ${op_len}  0
#   Should Match Regexp             ${nodes[1]['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   #Should Be Equal                 ${nodes[1]['data']['build_head']}  ${build_head}
#   Should Match Regexp             ${nodes[1]['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   Should Match Regexp             ${nodes[1]['data']['hostname']}  ^controller-

DME Should Exist
   [Arguments]  ${nodes}
   # {"data":{"key":{"name":"dme-647c84dc48-dx88z","node_type":1,"cloudlet_key":{"operator_key":{"name":"TDG"},"name":"automationBonnCloudlet"}},"notify_id":42,"build_master":"v1.0.2-24-g277eca5","build_head":"v1.0.2-24-g277eca5","hostname":"dme-647c84dc48-dx88z"}}

   ${found}=  Set Variable  ${False}

   : FOR  ${node}  IN  @{nodes}
   \  log to console  ${node['data']}
   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  ^dme-
   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal     ${node['data']['key']['type']}  dme 
   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  TDG
   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  mexplat-qa-cloudlet 

   # 'build_master': 'v1.2.4-rc4-2-g02efe6d0'
   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}   #\\-\\d{1,3}-\\b
   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}     #\\-\\d{1,3}-\\b

   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^dme-

   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}

   \  Exit For Loop If  ${found}

#   \  Log to console  ${node['data']['key']['cloudlet_key']['operator_key']['name']} 
   Run keyword if  ${found}==False  fail  DME Not Found

Hamburg CRM Should Exist
   [Arguments]  ${nodes}
   #{'key': {'name': 'automationHamburgCloudlet', 'node_type': 2, 'cloudlet_key': {'operator_key': {'name': 'TDG'}, 'name': 'automationHamburgCloudlet'}}, 'notify_id': 107, 'build_master': 'v1.0.2-24-g277eca5', 'build_head': 'v1.0.2-24-g277eca5', 'hostname': 'automationHamburgCloudlet'}

   ${found}=  Set Variable  ${False}

   : FOR  ${node}  IN  @{nodes}
   \  log to console  ${node['data']}
   \  ${name_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['name']}  automationHamburgCloudlet 
   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal As Integers    ${node['data']['key']['node_type']}  2
   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  TDG
   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  automationHamburgCloudlet

   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}   #\\-\\d{1,3}-\\b
   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}   #\\-\\d{1,3}-\\b

   \  ${host_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['hostname']}  automationHamburgCloudlet

   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}

   \  Exit For Loop If  ${found}

#   \  Log to console  ${node['data']['key']['cloudlet_key']['operator_key']['name']}
   Run keyword if  ${found}==False  fail  Hamburg CRM Not Found

Azure CRM Should Exist
   [Arguments]  ${nodes}
   #{'key': {'name': 'crmazurecentral-76b7d5b66-wh2k7', 'node_type': 2, 'cloudlet_key': {'operator_key': {'name': 'azure'}, 'name': 'automationAzureCentralCloudlet'}}, 'notify_id': 104, 'build_master': 'v1.0.2-24-g277eca5', 'build_head': 'v1.0.2-24-g277eca5', 'hostname': 'crmazurecentral-76b7d5b66-wh2k7'}
   ${found}=  Set Variable  ${False}

   : FOR  ${node}  IN  @{nodes}
   \  log to console  ${node['data']}
   #\  ${name_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['name']}  automationHamburgCloudlet
   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  ^gitlab-qa 

   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['type']}  crm 
   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  azure
   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  automationAzureCentralCloudlet

   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b
   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b

   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^gitlab-qa

   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}

   \  Exit For Loop If  ${found}

   Run keyword if  ${found}==False  fail  Azure CRM Not Found

GCP CRM Should Exist
   [Arguments]  ${nodes}
  #{'key': {'name': 'crmgcpcentral-84f984898d-q54pv', 'node_type': 2, 'cloudlet_key': {'operator_key': {'name': 'gcp'}, 'name': 'automationGcpCentralCloudlet'}}, 'notify_id': 3, 'build_master': 'v1.0.2-24-g277eca5', 'build_head': 'v1.0.2-24-g277eca5', 'hostname': 'crmgcpcentral-84f984898d-q54pv'}

   ${found}=  Set Variable  ${False}

   : FOR  ${node}  IN  @{nodes}
   \  log to console  ${node['data']}
   #\  ${name_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['name']}  automationHamburgCloudlet
   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  ^gitlab-qa

   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['key']['type']}  crm 
   \  ${operator_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['organization']}  gcp 
   \  ${cloudlet_match}=  Run Keyword And Return Status  Should Be Equal            ${node['data']['key']['cloudlet_key']['name']}  automationGcpCentralCloudlet

   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b
   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}    #\\-\\d{1,3}-\\b

   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^gitlab-qa

   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${operator_match} and ${cloudlet_match} and ${master_match} and ${head_match} and ${host_match}

   \  Exit For Loop If  ${found}

   Run keyword if  ${found}==False  fail  GCP CRM Not Found

Controllerx Should Exist
   [Arguments]   ${nodes}
   #{"data":{"key":{"name":"10.12.0.90:55001","node_type":3,"cloudlet_key":{"operator_key":{}}},"build_master":"v1.0.2-24-g277eca5","build_head":"v1.0.2-24-g277eca5","hostname":"controller-f8459444c-k6j2j"}}

   ${found}=  Set Variable  ${False}
 
   : FOR  ${node}  IN  @{nodes}
   \  log to console  andy
#${check1}=    Run Keyword And Return Status    Should Be Equal As Strings    ${accountNumChk}    6
#Run Keyword If     not ${check1}    Should Be Equal As Strings    ${accountNumChk}    7
   \  log to console  ${node['data']}
   \  ${name_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
   \  ${type_match}=  Run Keyword And Return Status  Should Be Equal As Integers    ${node['data']['key']['node_type']}  3
   \  ${op_len}=  Get Length  ${node['data']['key']['cloudlet_key']['operator_key']}
   \  ${len_match}=  Run Keyword And Return Status  Should Be Equal As Integers     ${op_len}  0
   \  ${master_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   \  ${build_head}=  Catenate  SEPARATOR=  ${nodes[0]['data']['build_master']}  +

#   \  ${head_match}=  Run Keyword And Return Status  Should Be Equal                ${node['data']['build_head']}  ${build_head}
   \  ${head_match}=  Run Keyword And Return Status  Should Match Regexp          ${node['data']['build_head']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b

   \  ${host_match}=  Run Keyword And Return Status  Should Match Regexp            ${node['data']['hostname']}  ^controller-

   \  ${found}=  Run Keyword And Return Status  Should Be True  ${name_match} and ${type_match} and ${len_match} and ${master_match} and ${head_match} and ${host_match}
   #Run Keyword  Should Be True  ${name_match} and ${type_match} and ${len_match} and ${master_match} and ${head_match} and ${host_match}

   \  Exit For Loop If  ${found}

   \  Log to console  ${found}
   Run keyword if  ${found}==False  fail  Controller Not Found 
   #[return]  ${found}

Get Number Of CRMs
   [Arguments]   ${nodes}
   #{"data":{"key":{"name":"10.12.0.90:55001","node_type":3,"cloudlet_key":{"operator_key":{}}},"build_master":"v1.0.2-24-g277eca5","build_head":"v1.0.2-24-g277eca5","hostname":"controller-f8459444c-k6j2j"}}

   ${count}=  Set Variable  0 
   
   : FOR  ${node}  IN  @{nodes}
   \  Log to console  andy
   \  Log to console  ${count}
   \  Log to console  andy2
#   \  ${count}=  Evaluate  ${count} + 1
   \  ${count}=  Run Keyword If  "${node['data']['key']['type']}" == "crm"   Evaluate  ${count}+1  ELSE  Set Variable  ${count}

   [Return]  ${count}
