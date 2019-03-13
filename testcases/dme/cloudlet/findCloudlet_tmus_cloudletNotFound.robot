*** Settings ***
Documentation   FindCloudlet - request shall return FIND_NOT_FOUND

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables      shared_variables.py
	
Suite Setup      Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0
${access_ports}    tcp:80,http:443,udp:10002
${operator_name}   tmus
${cloudlet_name1}  tmocloud-1
${cloudlet_lat1}   31
${cloudlet_long1}  -91
${cloudlet_name2}  tmocloud-2
${cloudlet_lat2}   35
${cloudlet_long2}  -95

*** Test Cases ***
FindCloudlet - request shall return FIND_NOT_FOUND when requesting an operator that doesnt exist
    [Documentation]
    ...  send findCloudlet with an operator that does not exist. return 'FIND_NOTFOUND'

      Register Client
      ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  carrier_name=dummyoperator  latitude=31  longitude=-91

      Should Be Equal  ${error_msg}  find cloudlet not found:status: FIND_NOTFOUND\ncloudlet_location {\n}\n 

*** Keywords ***
Setup
    #Create Operator        operator_name=${operator_name} 
    Create Developer
    Create Flavor
    #Create Cloudlet	   cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}  latitude=${cloudlet_lat1}  longitude=${cloudlet_long1}
    #Create Cloudlet	   cloudlet_name=${cloudlet_name2}  operator_name=${operator_name}  latitude=${cloudlet_lat2}  longitude=${cloudlet_long2}
    Create Cluster Flavor
    Create Cluster
    Create App             access_ports=${access_ports} 
    ${appinst_1}=          Create App Instance    cloudlet_name=${cloudlet_name1}  operator_name=${operator_name}  cluster_instance_name=autocluster

    Set Suite Variable  ${appinst_1} 
