*** Settings ***
Documentation   ShowAppInstClient requests 

Library         MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${tmus_operator_name}  tmus
${tmus_cloudlet_name}  tmocloud-1  #has to match crm process startup parms
${app_name}  automation_api_app   
${developer_name}  MobiledgeX
${app_version}  1.0

${tmus_cloudlet_latitude}	  35
${tmus_cloudlet longitude}	  -95

${region}=  US

*** Test Cases ***
ShowAppInstClient - request shall return the FindCloudlet requests
   [Documentation]
   ...  send ShowAppInstClient 
   
   Register Client	app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_name}

   # posting {"appinstclientkey":{"key":{"app_key":{"name":"automation_api_app","organization":"MobiledgeX","version":"1.0"},"cluster_inst_key":{"cloudlet_key":{"name":"tmocloud-1","organization":"tmus"},"cluster_key":{"name":"autoclusterautomation"},"organization":"MobiledgeX"}}},"region":"US"}

   Show App Instance Client Metrics  region=US  app_name=automation_api_app  developer_org_name=MobiledgeX  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation
   ${pre}=  Get Show App Instance Client Metrics Output
   ${len_pre}=  Get Length  ${pre}
   ${pre_last}=  Set Variable  ${pre[-1]['data']['location']['timestamp']['seconds']}
  
   Values Should Be Valid  ${pre}

   ${t}=  Show App Instance Client Metrics  region=US  app_name=automation_api_app  developer_org_name=MobiledgeX  app_version=1.0  cloudlet_name=tmocloud-1  operator_org_name=tmus  cluster_instance_name=autoclusterautomation  use_thread=${True}
   Sleep  1 second
   ${cloudlet}=  Find Cloudlet  carrier_name=${tmus_operator_name}  latitude=35  longitude=-94

   MexMasterController.Wait For Replies  ${t}
    
   ${metrics}=  Get Show App Instance Client Metrics Output
   ${len_metrics}=  Get Length  ${metrics}
   ${metrics_last}=  Set Variable  ${metrics[-1]['data']['location']['timestamp']['seconds']}

   Should Be True  ${len_metrics} == ${len_pre}+1
   Should Be True  ${metrics_last} > ${pre_last}  

   Values Should Be Valid  ${metrics}

*** Keywords ***
Values Should Be Valid
   [Arguments]  ${metrics}

   FOR  ${m}  IN  @{metrics}
      Should Be Equal  ${m['data']['client_key']['key']['app_key']['organization']}  ${developer_name} 
      Should Be Equal  ${m['data']['client_key']['key']['app_key']['name']}  ${app_name}
      Should Be Equal  ${m['data']['client_key']['key']['app_key']['version']}  ${app_version}
      Should Be Equal  ${m['data']['client_key']['key']['cluster_inst_key']['cloudlet_key']['organization']}  ${tmus_operator_name}
      Should Be Equal  ${m['data']['client_key']['key']['cluster_inst_key']['cloudlet_key']['name']}  ${tmus_cloudlet_name}
  
      Length Should Be  ${m['data']['client_key']['uuid']}  27 

      Should Be True  ${m['data']['location']['latitude']} > -90 and ${m['data']['location']['latitude']} < 90
      Should Be True  ${m['data']['location']['longitude']} > -180 and ${m['data']['location']['longitude']} < 180 
      #Should Be True  ${m['data']['location']['horizontal_accuracy']} > 0
      #Should Be True  ${m['data']['location']['vertical_accuracy']} > 0
      #Should Be True  ${m['data']['location']['altitude']} > 0
      #Should Be True  ${m['data']['location']['speed']} > 0

      Should Be True  ${m['data']['location']['timestamp']['seconds']} > 0
      Should Be True  ${m['data']['location']['timestamp']['nanos']} > 0
   END
