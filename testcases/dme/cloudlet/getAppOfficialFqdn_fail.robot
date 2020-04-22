*** Settings ***
Documentation  GetAppOfficialFqdn fail 

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
# ECQ-2096
GetAppOfficialFqdn - request without cookie shall return error
    [Documentation]
    ...  send GetAppOfficialFqdn without cookie
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Get App Official FQDN  latitude=37  longitude=-96
    Should Contain  ${error_msg}  status = StatusCode.UNAUTHENTICATED 
    Should Contain  ${error_msg}  details = "VerifyCookie failed: missing cookie" 

# ECQ-2097
GetAppOfficialFqdn - request with bad cookie shall return error
    [Documentation]
    ...  send GetAppOfficialFqdn with bad cookie
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Get App Official FQDN  session_cookie=x  latitude=37  longitude=-96
    Should Contain  ${error_msg}  status = StatusCode.UNAUTHENTICATED
    Should Contain  ${error_msg}  details = "token contains an invalid number of segments"

# ECQ-2098
GetAppOfficialFqdn - request with invalid lat/long shall return error
    [Documentation]
    ...  send GetAppOfficialFqdn with invalid lat/long 
    ...  verify proper error is received

    Register Client   developer_org_name=${platos_developer_name}  app_name=${platos_app_name}

    ${error_msg}=  Run Keyword And Expect Error  *  Get App Official FQDN  latitude=37  longitude=-916 
    Should Contain  ${error_msg}  status = StatusCode.INVALID_ARGUMENT
    Should Contain  ${error_msg}  details = "Invalid GpsLocation"

    ${error_msg}=  Run Keyword And Expect Error  *  Get App Official FQDN  latitude=337  longitude=-91
    Should Contain  ${error_msg}  status = StatusCode.INVALID_ARGUMENT
    Should Contain  ${error_msg}  details = "Invalid GpsLocation"

    ${error_msg}=  Run Keyword And Expect Error  *  Get App Official FQDN  latitude=337  longitude=-916
    Should Contain  ${error_msg}  status = StatusCode.INVALID_ARGUMENT
    Should Contain  ${error_msg}  details = "Invalid GpsLocation"

*** Keywords ***
Setup
    Create Flavor
    #Create Cluster	
    #Create Developer            developer_name=${platos_developer_name}
    Create App			developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  official_fqdn=${platos_uri} 
    #Create App Instance         app_name=${platos_app_name}  developer_name=${platos_developer_name}  cloudlet_name=${platos_cloudlet_name}  operator_org_name=${platos_operator_name}  uri=${platos_uri}  cluster_instance_name=autocluster

