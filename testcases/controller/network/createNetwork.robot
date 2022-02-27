#-*- coding: robot -*-

*** Settings ***
Documentation  CreateNetwork

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}    #auto_login=${False}
Library  MexApp
Library  String
Library  DateTime

Test Setup      Setup
Test Teardown   Teardown

Test Timeout  3m

*** Variables ***
${nogo}=  ${True}
${cloudlet_name_crm}  automationDallasCloudlet
#${cloudlet_name_crm}  qa-anthos
#${cloudlet_name_crm}  dfw-vsphere
#${cloudlet_name_crm}  DFWVMW2
#${cloudlet_name_crm}  automationBuckhornCloudlet
${operator_name_crm}  packet
#${operator_name_crm}  GDDT
${developer_org_name}  automation_dev_org
#${developer_org_name}  ${developer_org_name_automation}
${developer_org_name_automation}=  ${developer_org_name}
${connect1}=    ConnectToLoadBalancer
${connect2}=    ConnectToClusterNodes
${connect3}=    ConnectToAll
${region}  US
${fedorg}=  86868686noorghere
${error_400_networkname}=  (\'code=400\', \'error={"message":"Invalid network name"}\')
${error_400_cloudletorg}=  (\'code=400\', \'error={"message":"Invalid organization name"}\')
${error_400_cloudletname}=  KeyError: 'cloudlet_key'
${error_400_connectiontype}=  (\'code=400\', \'error={"message":"Invalid connection type"}\')
${error_400_routescidr}=  (\'code=400\', \'error={"message":"Invalid route destination cidr"}\')
${error_400_routeshop}=  (\'code=400\', \'error={"message":"Invalid next hop"}\')
${region_err}=  XXX
${region_empty}= 
${error_400_noregion}=  (\'code=400\', \'error={"message":"No region specified"}\')
${org_notfound}=  elknudmot
${error_400_orgnotfound}=  (\'code=400\', \'error={"message":"Org ${org_notfound} not found"}\')
${cloudlet_notfound}=  elknudtelduolc
${error_400_cloudletnotfound}=  ('code=400', 'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_notfound}\\\\"} not found"}\')


#(\'code=400\', \'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"packet\\\\",\\\\"name\\\\":\\\\"elknudtelduolc\\\\"} not found"}\')

#Usage: mcctl network create [flags] [args]
#Required Args:
#  region                    Region name
#  cloudletorg               Organization of the cloudlet site
#  cloudlet                  Name of the cloudlet
#  name                      Network Name
#
#Optional Args:
#  federatedorg              Federated operator organization who shared this cloudlet
#  route_list:empty              List of route_list, specify route_list:empty=true to clear
#  route_list:#.destinationcidr  Destination CIDR
#  route_list:#.nexthopip        Next hop IP
#  connectiontype            Network connection type, one of Undefined, ConnectToLoadBalancer, ConnectToClusterNodes, ConnectToAll
#    def _build(self, network_name=None, cloudlet_name=None, cloudlet_org=None, connection_type=None, federated_org=None, connection_type=None,  route_list=[], include_fields=False, use_defaults=True):

*** Test Cases ***

#ECQ-4389
CreateNetwork - shall be able to create with long network name
   [Documentation]
   ...  - send CreateNetwork with long network name for each type network
   ...  - verify networks are created

   ${name}=  Generate Random String  length=50
   ${name_1}=  Generate Random String  length=50
   ${name_2}=  Generate Random String  length=50
   ${name_3}=  Generate Random String  length=50
   &{route1}=  Create Dictionary  destination_cidr=11.71.71.1/16  next_hop_ip=11.70.70.1
   &{route2}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop_ip=11.70.70.2
   &{route3}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop_ip=11.70.70.3
   @{routelist1}=  Create List  ${route1}
   @{routelist2}=  Create List  ${route1}  ${route2}
   @{routelist3}=  Create List  ${route1}  ${route2}  ${route3}

   ${network1_return}=  Create Network  region=${region}  token=${token}  network_name=${name}${name_1}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}

   ${network2_return}=  Create Network  region=${region}  token=${token}  network_name=${name}${name_2}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect2}  route_list=${routelist2}

   ${network3_return}=  Create Network  region=${region}  token=${token}  network_name=${name}${name_3}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect3}  route_list=${routelist3}

   Should Be Equal  ${network1_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network1_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm} 
   Should Be Equal  ${network1_return['data']['connection_type']}  ${connect1}
   Should Be Equal  ${network1_return['data']['routes']}  ${routelist1}
   Should Be Equal  ${network1_return['data']['key']['name']}  ${name}${name_1}

   Should Be Equal  ${network2_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network2_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network2_return['data']['connection_type']}  ${connect2}
   Should Be Equal  ${network2_return['data']['routes']}  ${routelist2}
   Should Be Equal  ${network2_return['data']['key']['name']}  ${name}${name_2}

   Should Be Equal  ${network3_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network3_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network3_return['data']['connection_type']}  ${connect3}
   Should Be Equal  ${network3_return['data']['routes']}  ${routelist3}
   Should Be Equal  ${network3_return['data']['key']['name']}  ${name}${name_3}

#ECQ-4390
CreateNetwork - shall be able to create network with numbers in name
   [Documentation]
   ...  - send CreateNetwork with numbers in network name for each type network
   ...  - verify networks are created

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   ${name_1}=  Generate Random String  length=50
   ${name_2}=  Generate Random String  length=50
   ${name_3}=  Generate Random String  length=50
   &{route1}=  Create Dictionary  destination_cidr=11.71.71.1/16  next_hop_ip=11.70.70.1
   &{route2}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop_ip=11.70.70.2
   &{route3}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop_ip=11.70.70.3
   @{routelist1}=  Create List  ${route1}
   @{routelist2}=  Create List  ${route1}  ${route2}
   @{routelist3}=  Create List  ${route1}  ${route2}  ${route3}

   ${network1_return}=  Create Network  region=${region}  token=${token}  network_name=${name_1}${epoch}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}

   ${network2_return}=  Create Network  region=${region}  token=${token}  network_name=${name_2}${epoch}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect2}  route_list=${routelist2}

   ${network3_return}=  Create Network  region=${region}  token=${token}  network_name=${name_3}${epoch}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect3}  route_list=${routelist3}

   Should Be Equal  ${network1_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network1_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network1_return['data']['connection_type']}  ${connect1}
   Should Be Equal  ${network1_return['data']['routes']}  ${routelist1}
   Should Be Equal  ${network1_return['data']['key']['name']}  ${name_1}${epoch} 

   Should Be Equal  ${network2_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network2_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network2_return['data']['connection_type']}  ${connect2}
   Should Be Equal  ${network2_return['data']['routes']}  ${routelist2}
   Should Be Equal  ${network2_return['data']['key']['name']}  ${name_2}${epoch}

   Should Be Equal  ${network3_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network3_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network3_return['data']['connection_type']}  ${connect3}
   Should Be Equal  ${network3_return['data']['routes']}  ${routelist3}
   Should Be Equal  ${network3_return['data']['key']['name']}  ${name_3}${epoch}

#ECQ-4391
CreateNetwork - shall be able to update and show network
   [Documentation]
   ...  - send CreateNetwork with numbers and letters in network name for each type network
   ...  - verify networks are created
   ...  - send UpdateNetwork and verify networks are updated

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   ${name_1}=  Generate Random String  length=5
   &{route1}=  Create Dictionary  destination_cidr=11.71.71.1/16  next_hop_ip=11.70.70.1
   &{route2}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop_ip=11.70.70.2
   @{routelist1}=  Create List  ${route1}
   @{routelist2}=  Create List  ${route1}  ${route2}

   ${network1_return}=  Create Network  region=${region}  token=${token}  network_name=${name_1}${epoch}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}

   ${network1_update}=  Update Network  region=${region}  token=${token}  network_name=${name_1}${epoch}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect2}  route_list=${routelist2}

   ${network1_show}=  Show Network  region=${region}  token=${token}  network_name=${name_1}${epoch}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}

   Should Be Equal  ${network1_return['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network1_return['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network1_return['data']['connection_type']}  ${connect1}
   Should Be Equal  ${network1_return['data']['routes']}  ${routelist1}
   Should Be Equal  ${network1_return['data']['key']['name']}  ${name_1}${epoch}

   Should Be Equal  ${network1_update['data']['key']['cloudlet_key']['name']}  ${cloudlet_name_crm}
   Should Be Equal  ${network1_update['data']['key']['cloudlet_key']['organization']}  ${operator_name_crm}
   Should Be Equal  ${network1_update['data']['connection_type']}  ${connect2}
   Should Be Equal  ${network1_update['data']['routes']}  ${routelist2}
   Should Be Equal  ${network1_update['data']['key']['name']}  ${name_1}${epoch}

   Should Be Equal  ${network1_show}[0][data][key][cloudlet_key][name]  ${cloudlet_name_crm}
   Should Be Equal  ${network1_show}[0][data][key][cloudlet_key][organization]  ${operator_name_crm}
   Should Be Equal  ${network1_show}[0][data][connection_type]  ${connect2}
   Should Be Equal  ${network1_show}[0][data][routes]  ${routelist2}
   Should Contain   ${network1_show}[0][data][key][name]}  ${name_1}${epoch}

#ECQ-4392
CreateNetwork - shall be able to handle errors 
   [Documentation]
   ...  - send CreateNetwork with invalid values
   ...  - send CreateNetwork with missing arguments
   ...  - verify errors are returned

   ${epoch}=  Get Time  epoch
   ${epoch}=  Convert To String  ${epoch}
   ${name_1}=  Generate Random String  length=5
   &{route1}=  Create Dictionary  destination_cidr=11.71.71.1/16  next_hop_ip=11.70.70.1
   &{route2}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop_ip=11.70.70.2
   &{route_errcidr}=  Create Dictionary  destination=11.71.71.1/16  next_hop_ip=11.70.70.1
   &{route_errhop}=  Create Dictionary  destination_cidr=12.72.72.1/16  next_hop=11.70.70.2
   @{routelist1}=  Create List  ${route1}
   @{routelist2}=  Create List  ${route1}  ${route2}
   @{routelist_errcidr}=  Create List  ${route_errcidr}
   @{routelist_errhop}=  Create List  ${route_errhop}
   ${name_err}=  Set Variable  ${name_1}${epoch}

#   Log To Console  ${\n}federated_org specified not found during create${\n}
   ${network1_create_err}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}  federated_org=${fedorg}
   ${error_400_createfed}=  Set Variable  (\'code=400\', \'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_crm}\\\\",\\\\"federated_organization\\\\":\\\\"${fedorg}\\\\"} not found"}\')
   Should Contain  ${network1_create_err}  ${error_400_createfed}
#   Log To Console  ${\n}federated_org specified not found during update${\n}
   ${network1_update_err}=  Run Keyword and Expect Error  *    Update Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect2}  route_list=${routelist2}  federated_org=${fedorg}
   ${error_400_updatefed}=  Set Variable  (\'code=400\', \'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_crm}\\\\",\\\\"federated_organization\\\\":\\\\"${fedorg}\\\\"},\\\\"name\\\\":\\\\"${name_err}\\\\"} not found"}\')
   Should Contain  ${network1_update_err}  ${error_400_updatefed}
#   Log To Console  ${\n}federated_org specified not found during show${\n}
   ${error_400_showfed}=  Set Variable  (\'code=400\', \'error={"message":"Network key {\\\\"cloudlet_key\\\\":{\\\\"organization\\\\":\\\\"${operator_name_crm}\\\\",\\\\"name\\\\":\\\\"${cloudlet_name_crm}\\\\",\\\\"federated_organization\\\\":\\\\"${fedorg}\\\\"},\\\\"name\\\\":\\\\"${name_err}\\\\"} not found"}\')
   ${network1_show_err}=  Run Keyword and Ignore Error    Show Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  federated_org=${fedorg}
   Should Be Equal  ${network1_update_err}  ${error_400_showfed}  

#   Log To Console  ${\n}network name misisng from command
   ${err_networkname}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}  federated_org=${fedorg}
   Should Contain  ${err_networkname}  ${error_400_networkname}
#   Log To Console  ${\n}cloudlet_org missing from command
   ${err_cloudletorg}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  #cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}  federated_org=${fedorg}
   Should Contain   ${err_cloudletorg}  ${error_400_cloudletorg}
#   Log To Console  ${\n}cloudlet org specified in command not found
   ${err_orgnotfound}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${org_notfound}  connection_type=${connect1}  route_list=${routelist1}  federated_org=${fedorg}
   Should Contain   ${err_orgnotfound}  ${error_400_orgnotfound}
#   Log To Console  ${\n}cloudlet_name missing from command
   ${err_cloudletname}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  #cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}  federated_org=${fedorg}
   Should Contain   ${err_cloudletname}  ${error_400_cloudletname}
#   Log To Console  ${\n}cloudlet name specified in command not found
   ${err_cloudletnotfound}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_notfound}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist1}  #federated_org=${fedorg}
   Should Contain   ${err_cloudletnotfound}  ${error_400_cloudletnotfound}
#   Log To Console  ${\n}connection_type missing from command
   ${err_connectiontype}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  #connection_type=${connect1}  route_list=${routelist1}  federated_org=${fedorg}
   Should Contain   ${err_connectiontype}  ${error_400_connectiontype}
#   Log To Console  ${\n}Invalid route destination cidr
   ${err_routescidr}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist_errcidr} #federated_org=${fedorg}
   Should Contain   ${err_routescidr}  ${error_400_routescidr}
#   Log To Console  ${\n}Invalid next hop
   ${err_routeshop}=  Run Keyword and Expect Error  *    Create Network  region=${region}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist_errhop} #federated_org=${fedorg}
   Should Contain   ${err_routeshop}  ${error_400_routeshop}
#   Log To Console  ${\n}region missing from command
   ${error_400_region}=  Set Variable  (\'code=400\', \'error={"message":"Region \\\\"${region_err}\\\\" not found"}\')
   ${err_region}=  Run Keyword and Expect Error  *    Create Network  region=${region_err}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist_errhop} #federated_org=${fedorg}
   Should Contain   ${err_region}  ${error_400_region}
#   Log To Console  ${\n}region specified not found
   ${err_noregion}=  Run Keyword and Expect Error  *    Create Network  region=${region_empty}  token=${token}  network_name=${name_err}  cloudlet_name=${cloudlet_name_crm}  cloudlet_org=${operator_name_crm}  connection_type=${connect1}  route_list=${routelist_errhop} #federated_org=${fedorg}
   Should Contain   ${err_noregion}  ${error_400_noregion}


*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

Teardown
    Cleanup Provisioning
