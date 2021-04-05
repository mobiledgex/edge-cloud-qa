*** Settings ***
Documentation   ShowAppInstClient requests 

Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-1  #has to match crm process startup parms
${app_name}  automation_api_app   
${developer_name}  automation_dev_org
${app_version}  1.0

${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

${region}=  US

*** Test Cases ***
# ECQ-2091
ShowAppInstClient - request shall return the FindCloudlet requests
   [Documentation]
   ...  send ShowAppInstClient 
   ...  verify FindCloudlet info is returned
 
   Register Client	app_name=${app_name_automation}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}

   ${t}=  Show App Instance Client Metrics  region=US  app_name=${app_name_automation}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation  use_thread=${True}
   Sleep  1 second

   ${pre}=  Get Show App Instance Client Metrics Output
   ${len_pre}=  Get Length  ${pre}
   ${pre_last}=  Run Keyword If  ${len_pre} == 0  Set Variable  0  ELSE  Set Variable  ${pre[-1]['data']['location']['timestamp']['seconds']}

   ${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

   MexMasterController.Wait For Replies  ${t}
    
   ${metrics}=  Get Show App Instance Client Metrics Output
   ${len_metrics}=  Get Length  ${metrics}
   ${metrics_last}=  Set Variable  ${metrics[-1]['data']['location']['timestamp']['seconds']}

   Should Be True  ${len_metrics} == ${len_pre}+1
   Should Be True  ${metrics_last} > ${pre_last}  

   Values Should Be Valid  ${pre}

   Values Should Be Valid  ${metrics}

# ECQ-2092
ShowAppInstClient - request with unique_id shall return the FindCloudlet requests
   [Documentation]
   ...  send ShowAppInstClient
   ...  verify FindCloudlet with unique_id is returned

   Register Client      app_name=${app_name_automation}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}  unique_id=123456789012345678901234567  unique_id_type=automation

   ${t}=  Show App Instance Client Metrics  region=US  app_name=${app_name_automation}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation  unique_id=123456789012345678901234567  use_thread=${True}
   #${t}=  Show App Instance Client Metrics  region=US  developer_org_name=${developer_org_name_automation}  token=${super_token}  use_thread=${True}  use_defaults=False
   Sleep  1 second

#   Show App Instance Client Metrics  region=US  app_name=automation_api_app  developer_org_name=MobiledgeX  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation
   ${pre}=  Get Show App Instance Client Metrics Output
   ${len_pre}=  Get Length  ${pre}
   ${pre_last}=  Run Keyword If  ${len_pre} == 0  Set Variable  0  ELSE  Set Variable  ${pre[-1]['data']['location']['timestamp']['seconds']}

   ${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

   MexMasterController.Wait For Replies  ${t}

   ${metrics}=  Get Show App Instance Client Metrics Output
   ${len_metrics}=  Get Length  ${metrics}
   ${metrics_last}=  Set Variable  ${metrics[-1]['data']['location']['timestamp']['seconds']}

   Should Be Equal  ${metrics[-1]['data']['client_key']['unique_id']}  123456789012345678901234567
   Should Be Equal  ${metrics[-1]['data']['client_key']['unique_id_type']}  automation

   Should Be True  ${len_metrics} == ${len_pre}+1
   Should Be True  ${metrics_last} > ${pre_last}

   Values Should Be Valid  ${pre}

   Values Should Be Valid  ${metrics}

# ECQ-3793
ShowAppInstClient - request with appinst client key parms shall return the FindCloudlet requests
   [Documentation]
   ...  - send ShowAppInstClient with different combinations of appinst client key
   ...  - verify FindCloudlet is returned

   [Setup]  RegisterClient Setup

   [Template]  ShowAppInstClient Metrics Shall return FindCloudlet Request
   
   developer_org_name=${developer_org_name_automation}

   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}
   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  app_version=${app_version}
   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  app_version=${app_version}  unique_id=123456789012345678901234567
   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  app_version=${app_version}  unique_id=123456789012345678901234567  unique_id_type=automation
   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  unique_id=123456789012345678901234567 
   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  unique_id=123456789012345678901234567  unique_id_type=automation
   developer_org_name=${developer_org_name_automation}  app_name=${app_name_automation}  unique_id_type=automation

   developer_org_name=${developer_org_name_automation}  app_version=${app_version}  
   developer_org_name=${developer_org_name_automation}  app_version=${app_version}  unique_id=123456789012345678901234567
   developer_org_name=${developer_org_name_automation}  app_version=${app_version}  unique_id=123456789012345678901234567  unique_id_type=automation

   developer_org_name=${developer_org_name_automation}  unique_id=123456789012345678901234567
   developer_org_name=${developer_org_name_automation}  unique_id=123456789012345678901234567  unique_id_type=automation

   developer_org_name=${developer_org_name_automation}  unique_id_type=automation

# ECQ-3324
ShowAppInstClient - clients shall timeout via appinstclientcleanupinterval
   [Documentation]
   ...  Set appinst_client_cleanup_interval=10s
   ...  Send RegisterClient/FindCloudlet and send ShowAppInstClient
   ...  Wait 10s and verify ShowAppInstClient does not show the app

   ${settings_pre}=   Show Settings  region=${region}

   [Teardown]  Teardown Settings  ${settings_pre}

   Update Settings  region=${region}  appinst_client_cleanup_interval=10s

   ${settings_post}=   Show Settings  region=${region}

   ${app_name}=  Get Default App Name

   Create Flavor  region=${region}

   ${epochtime}=  Get Current Date  result_format=epoch
   ${app}=      Catenate  SEPARATOR=  app  ${epochtime}

   Create App     region=${region}  app_name=${app}
   Create App Instance  region=${region}  cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster

   Register Client      app_name=${app}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}

   ${t}=  Show App Instance Client Metrics  region=US  app_name=${app}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation  use_thread=${True}
   Sleep  1 second

   ${pre}=  Get Show App Instance Client Metrics Output
   ${len_pre}=  Get Length  ${pre}
   ${pre_last}=  Run Keyword If  ${len_pre} == 0  Set Variable  0  ELSE  Set Variable  ${pre[-1]['data']['location']['timestamp']['seconds']}

   ${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

   MexMasterController.Wait For Replies  ${t}

   ${metrics}=  Get Show App Instance Client Metrics Output
   ${len_metrics}=  Get Length  ${metrics}
   ${metrics_last}=  Set Variable  ${metrics[-1]['data']['location']['timestamp']['seconds']}

   Should Be True  ${len_metrics} == ${len_pre}+1
   Should Be True  ${metrics_last} > ${pre_last}

   ${t2}=  Show App Instance Client Metrics  region=US  app_name=${app}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation  use_thread=${True}
   Sleep  1 second

   ${post}=  Get Show App Instance Client Metrics Output
   ${len_post}=  Get Length  ${post}
   Should Be Equal  ${len_post}  ${len_pre}}

   Sleep  25s

   ${t3}=  Show App Instance Client Metrics  region=US  app_name=${app}  developer_org_name=${developer_org_name_automation}  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation  use_thread=${True}
   Sleep  1 second

   ${post2}=  Get Show App Instance Client Metrics Output
   ${len_post2}=  Get Length  ${post2}
   Should Be Equal  ${len_post2}  0
 
*** Keywords ***
Setup
   #Register Client      app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_name}
   #${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94
   ${super_token}=  Get Super Token

   Set Suite Variable  ${super_token}

Teardown Settings
   [Arguments]  ${settings}

   Update Settings  region=${region}  appinst_client_cleanup_interval=${settings['appinst_client_cleanup_interval']}  

   Cleanup Provisioning

RegisterClient Setup
   Setup
   Register Client      app_name=${app_name_automation}  app_version=${app_version}  developer_org_name=${developer_org_name_automation}  unique_id=123456789012345678901234567  unique_id_type=automation

ShowAppInstClient Metrics Shall return FindCloudlet Request
   [Arguments]  ${app_name}=${None}  ${app_version}=${None}  ${developer_org_name}=${None}  ${cloudlet_name}=${None}  ${operator_org_name}=${None}  ${unique_id}=${None}  ${unique_id_type}=${None}

   ${t}=  Show App Instance Client Metrics  region=US  app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_org_name}  unique_id=${unique_id}  unique_id_type=${unique_id_type}  token=${super_token}  use_thread=${True}  use_defaults=False
   Sleep  2 second

   ${pre}=  Get Show App Instance Client Metrics Output
   ${len_pre}=  Get Length  ${pre}
   ${pre_last}=  Run Keyword If  ${len_pre} == 0  Set Variable  0  ELSE  Set Variable  ${pre[-1]['data']['location']['timestamp']['seconds']}

   ${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

   MexMasterController.Wait For Replies  ${t}

   ${metrics}=  Get Show App Instance Client Metrics Output
   ${len_metrics}=  Get Length  ${metrics}
   ${metrics_last}=  Set Variable  ${metrics[-1]['data']['location']['timestamp']['seconds']}

   Should Be Equal  ${metrics[-1]['data']['client_key']['unique_id']}  123456789012345678901234567
   Should Be Equal  ${metrics[-1]['data']['client_key']['unique_id_type']}  automation

   Should Be True  ${len_metrics} == ${len_pre}+1
   Should Be True  ${metrics_last} > ${pre_last}

   Values Should Be Valid  ${pre}  app_check=${app_name}  version_check=${app_version}  developer_check=${developer_org_name}  cloudlet_check=${cloudlet_name}  operator_check=${operator_org_name}  id_check=${unique_id}  type_check=${unique_id_type}

   Values Should Be Valid  ${metrics}  app_check=${app_name}  version_check=${app_version}  developer_check=${developer_org_name}  cloudlet_check=${cloudlet_name}  operator_check=${operator_org_name}  id_check=${unique_id}  type_check=${unique_id_type}

Values Should Be Valid
   [Arguments]  ${metrics}  ${app_check}=${app_name}  ${version_check}=${app_version}  ${developer_check}=${developer_name}  ${cloudlet_check}=${tmus_operator_name}  ${operator_check}=${tmus_cloudlet_name}  ${id_check}=${None}  ${type_check}=${None} 

   FOR  ${m}  IN  @{metrics}
      log to console  ${app_check} ${developer_check} ${id_check} ${type_check}
      Run Keyword If  '${developer_check}' != '${None}'  Should Be Equal  ${m['data']['client_key']['app_inst_key']['app_key']['organization']}  ${developer_check} 
      Run Keyword If  '${app_check}' != '${None}'  Should Be Equal  ${m['data']['client_key']['app_inst_key']['app_key']['name']}  ${app_check}
      Run Keyword If  '${version_check}' != '${None}'  Should Be Equal  ${m['data']['client_key']['app_inst_key']['app_key']['version']}  ${app_version}
      Run Keyword If  '${operator_check}' != '${None}'  Should Be Equal  ${m['data']['client_key']['app_inst_key']['cluster_inst_key']['cloudlet_key']['organization']}  ${tmus_operator_name}
      Run Keyword If  '${cloudlet_check}' != '${None}'  Should Be Equal  ${m['data']['client_key']['app_inst_key']['cluster_inst_key']['cloudlet_key']['name']}  ${tmus_cloudlet_name}

      ${l}=  Get Length  ${m['data']['client_key']['unique_id']} 
      Should Be True  '${l}' > '0'
      #Should Be True   '${m['data']['client_key']['unique_id_type']}' == 'dme-ksuid' or '${m['data']['client_key']['unique_id_type']}' == 'automation'
      ${t}=  Get Length  ${m['data']['client_key']['unique_id_type']}
      Should Be True  '${t}' > '0'

      Run Keyword If  '${id_check}' != '${None}'     Should Be Equal   ${m['data']['client_key']['unique_id']}  ${id_check}
      Run Keyword If  '${type_check}' != '${None}'   Should Be Equal   ${m['data']['client_key']['unique_id_type']}  ${type_check}

      Run Keyword If  'latitude' in ${m['data']['location']}  Should Be True  ${m['data']['location']['latitude']} > -90 and ${m['data']['location']['latitude']} < 90
      Run Keyword If  'longitude' in ${m['data']['location']}  Should Be True  ${m['data']['location']['longitude']} > -180 and ${m['data']['location']['longitude']} < 180 
      #Should Be True  ${m['data']['location']['horizontal_accuracy']} > 0
      #Should Be True  ${m['data']['location']['vertical_accuracy']} > 0
      #Should Be True  ${m['data']['location']['altitude']} > 0
      #Should Be True  ${m['data']['location']['speed']} > 0

      Should Be True  ${m['data']['location']['timestamp']['seconds']} > 0
      Should Be True  ${m['data']['location']['timestamp']['nanos']} > 0
   END
