*** Settings ***
Documentation  DME metrics for PlatformFindCloudlet 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${dmuus_operator_name}  dmuus
${dmuus_cloudlet_name}  tmocloud-2  #has to match crm process startup parms

${cloudlet_name_dme}=  mexplat-qa-cloudlet
${operator_org_name_dme}=  GDDT

${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_uri}  automation.platos.com

${region}=  US

${api_collection_timer}=  30
${metrics_wait_time}=  45 s

*** Test Cases ***
# ECQ-4091
DMEMetrics - PlatformFindCloudlet shall generate metrics
   [Documentation]
   ...  - Send multiple PlatformFindCloudlet messages
   ...  - Verify all are collected 

   Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}

   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}
   
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Platform Find Cloudlet API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}  

   ${count}=  Set Variable  ${0}
   FOR  ${s}  IN  @{metrics['data'][0]['Series']}
      ${count}=  Evaluate  ${count}+${s['values'][0][1]}  # reqs field
   END

   Should Be Equal As Numbers  ${count}  10

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${app}  ${dmuus_cloudlet_name}  ${dmuus_operator_name}

# ECQ-4092
DMEMetrics - PlatformFindCloudlet with error shall generate metrics
   [Documentation]
   ...  - Send multiple PlatformFindCloudlet messages with error
   ...  - Verify all are collected

   Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}

   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=x  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=y  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=1  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=1  client_token=${fqdn.client_token}
#   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=x
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=3  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=4  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=5  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=6  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=7  client_token=${fqdn.client_token}
   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=1  client_token=${fqdn.client_token}
#   Run Keyword and Expect Error  *  Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}  session_cookie=x  use_defaults=${True}
   Sleep  ${metrics_wait_time}  # give time for the metrics to show in db

   ${metrics}=  Get Platform Find Cloudlet API Metrics  region=${region}  selector=api  developer_org_name=${developer}  app_name=${app}  app_version=${appvers}

   ${count}=  Set Variable  ${0}
   FOR  ${s}  IN  @{metrics['data'][0]['Series']}
      ${count}=  Evaluate  ${count}+${s['values'][0][1]}  # reqs field
   END

   Should Be Equal As Numbers  ${count}  10

   Metrics Headings Should Be Correct  ${metrics}

   Values Should Be In Range  ${metrics}  ${app}  ${Empty}  ${Empty}

*** Keywords ***
Setup
   Update Settings  region=${region}  dme_api_metrics_collection_interval=${api_collection_timer}s

   Create Flavor  region=${region}

   ${epochtime}=  Get Time  epoch
   ${app}=      Catenate  SEPARATOR=  app  ${epochtime}
   ${appauth}=  Catenate  SEPARATOR=  ${app}  auth
   ${developer}=  Get Default Developer Name
   ${appvers}=    Get Default App Version

   Create App     region=${region}  app_name=${app}  official_fqdn=${platos_uri}

   Create App Instance  region=${region}  cloudlet_name=${dmuus_cloudlet_name}  operator_org_name=${dmuus_operator_name}  cluster_instance_name=autocluster

   Register Client  app_name=${app}  app_version=${appvers}  developer_org_name=${developer}

   ${fqdn}=  Get App Official FQDN  latitude=34  longitude=-96

   Set Suite Variable  ${developer}
   Set Suite Variable  ${app}
   Set Suite Variable  ${appauth}
   Set Suite Variable  ${appvers}
   Set Suite Variable  ${fqdn}

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        dme-api
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  reqs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  errs
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cellID
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  foundCloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  foundOperator

   Should Be True  'apporg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'app' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'ver' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudletorg' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'cloudlet' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'dmeId' in ${metrics['data'][0]['Series'][0]['tags']}
   Should Be True  'method' in ${metrics['data'][0]['Series'][0]['tags']}

Values Should Be In Range
  [Arguments]  ${metrics}  ${app}  ${cloudlet}  ${operator}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${developer}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${appvers}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  PlatformFindCloudlet

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} >= 0
      Should Be Equal  ${reading[3]}  0
      Should Be Equal  ${reading[4]}  ${cloudlet}
      Should Be Equal  ${reading[5]}  ${operator}
   END

Values With Error Should Be In Range
  [Arguments]  ${metrics}  ${app_arg}  ${dev_arg}  ${ver_arg}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['apporg']}  ${dev_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['app']}  ${app_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['ver']}  ${ver_arg}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudletorg']}  ${operator_org_name_dme}
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['cloudlet']}  ${cloudlet_name_dme}
   Should Be True   '${metrics['data'][0]['Series'][0]['tags']['dmeId']}'.startswith('dme-')
   Should Be Equal  ${metrics['data'][0]['Series'][0]['tags']['method']}  PlatformFindCloudlet

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True   ${reading[1]} > 0
      Should Be True   ${reading[2]} >= 0
      Should Be Equal  ${reading[3]}  0
      Should Be Empty  ${reading[4]}
      Should Be Empty  ${reading[5]}
   END

