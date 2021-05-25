*** Settings ***
Documentation   FindCloudlet edge events key

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

*** Variables ***
${latitude}=  31
${longitude}=  -91

*** Test Cases ***
# ECQ-3421
FindCloudlet - request shall return edge events cookie
   [Documentation]
   ...  - send findCloudlet
   ...  - verify edge events cookie is correct
      
   Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=dmuus  latitude=${latitude}  longitude=${longitude}
   ${decoded_edge_cookie}=  Decoded Edge Events Cookie

   ${appinst}=  Show App Instances  region=US  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation} 

   log to console  ${decoded_edge_cookie}
   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
   Should Be Equal             ${cloudlet.fqdn}  tmocloud-1.dmuus.mobiledgex.net
   Should Be Equal As Numbers  ${cloudlet.cloudlet_location.latitude}   ${latitude}
   Should Be Equal As Numbers  ${cloudlet.cloudlet_location.longitude}  ${longitude}

   # verify edge events cookie
   Should Be True  len('${cloudlet.edge_events_cookie}') > 100
   Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['latitude']}   ${latitude} 
   Should Be Equal As Numbers  ${decoded_edge_cookie['key']['location']['longitude']}  ${longitude}
   Should Be True  ${decoded_edge_cookie['exp']} - ${decoded_edge_cookie['iat']} == 600
   Should Be Equal  ${decoded_edge_cookie['key']['cloudletname']}  ${appinst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}
   Should Be Equal  ${decoded_edge_cookie['key']['cloudletorg']}  ${appinst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}
   Should Be Equal  ${decoded_edge_cookie['key']['clustername']}  ${appinst[0]['data']['key']['cluster_inst_key']['cluster_key']['name']}
   Should Be Equal  ${decoded_edge_cookie['key']['clusterorg']}  ${appinst[0]['data']['key']['cluster_inst_key']['organization']}

