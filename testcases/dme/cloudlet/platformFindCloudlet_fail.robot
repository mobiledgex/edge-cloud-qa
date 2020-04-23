*** Settings ***
Documentation  PlatformFindCloudlet fail 

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${dmuus_operator_name}  dmuus
${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_cloudlet_name}  default
${platos_operator_name}  developer
${platos_uri}  automation.platos.com
${app_version}  1.0

*** Test Cases ***
# ECQ-2093
PlatformFindCloudlet - request without cookie shall return error
    [Documentation]
    ...  send PlatformFindCloudlet without cookie
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${dmuus_operator_name}  client_token=x
    Should Contain  ${error_msg}  status = StatusCode.UNAUTHENTICATED 
    Should Contain  ${error_msg}  details = "VerifyCookie failed: missing cookie" 

# ECQ-2094
PlatformFindCloudlet - request with bad cookie shall return error
    [Documentation]
    ...  send PlatformFindCloudlet with bad cookie
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  session_cookie=x  carrier_name=${dmuus_operator_name}  client_token=x 
    Should Contain  ${error_msg}  status = StatusCode.UNAUTHENTICATED
    Should Contain  ${error_msg}  details = "token contains an invalid number of segments"

# ECQ-2095
PlatformFindCloudlet - request with bad client_token shall return error
    [Documentation]
    ...  send PlatformFindCloudlet with bad client_token
    ...  verify proper error is received

    Register Client   developer_org_name=${platos_developer_name}  app_name=${platos_app_name}

    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${dmuus_operator_name} 
    Should Contain  ${error_msg}  status = StatusCode.INVALID_ARGUMENT
    Should Contain  ${error_msg}  details = "Missing ClientToken"

 #EDGECLOUD-2583 - PlatformFindCloudlet with bad client_token returns wrong status code
    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${dmuus_operator_name}  client_token=x
    Should Contain  ${error_msg}  status = StatusCode.UNKNOWNxxx
    Should Contain  ${error_msg}  details = "unable to decode token: illegal base64 data at input byte 0"

*** Keywords ***
Setup
    Create Flavor
    #Create Cluster	
    #Create Developer            developer_name=${platos_developer_name}
    Create App			developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  official_fqdn=${platos_uri} 
    #Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_org_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

