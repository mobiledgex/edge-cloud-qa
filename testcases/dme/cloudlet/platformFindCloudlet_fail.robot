*** Settings ***
Documentation  PlatformFindCloudlet fail 

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${tmus_operator_name}  tmus
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
${app_version}  1.0

*** Test Cases ***
# ECQ-2093
PlatformFindCloudlet - request without cookie shall return error
    [Documentation]
    ...  send PlatformFindCloudlet without cookie
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=x
    Should Contain  ${error_msg}  status = StatusCode.UNAUTHENTICATED 
    Should Contain  ${error_msg}  details = "VerifyCookie failed: missing cookie" 

# ECQ-2094
PlatformFindCloudlet - request with bad cookie shall return error
    [Documentation]
    ...  send PlatformFindCloudlet with bad cookie
    ...  verify proper error is received

    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  session_cookie=x  carrier_name=${tmus_operator_name}  client_token=x 
    Should Contain  ${error_msg}  status = StatusCode.UNAUTHENTICATED
    Should Contain  ${error_msg}  details = "token contains an invalid number of segments"

# ECQ-2095
PlatformFindCloudlet - request with bad client_token shall return error
    [Documentation]
    ...  send PlatformFindCloudlet with bad client_token
    ...  verify proper error is received

    Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}

    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${tmus_operator_name} 
    Should Contain  ${error_msg}  status = StatusCode.INVALID_ARGUMENT
    Should Contain  ${error_msg}  details = "Missing ClientToken"

    #EDGECLOUD-2583 - PlatformFindCloudlet with bad client_token returns wrong status code
    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=x
    Should Contain  ${error_msg}  status = StatusCode.INVALID_ARGUMENT
    Should Contain  ${error_msg}  details = "Invalid ClientToken"

# ECQ-2127
PlatformFindCloudlet - request with non-samsung session cookie shall return error
    [Documentation]
    ...  send PlatformFindCloudlet with non-samsung session cookie
    ...  verify proper error is received

    ${t}=  Get Time  epoch

    Create App  app_name=app${t}  developer_org_name=MobilegeX  access_ports=tcp:1  official_fqdn=${samsung_uri}   #permits_platform_apps=${True}

    Register Client  app_name=app${t}  developer_org_name=MobilegeX

    ${fqdn}=  Get App Official FQDN  latitude=37  longitude=-96

    # send without token
    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${tmus_operator_name}
    Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
    Should Contain  ${error_msg}  details = "API Not allowed for developer: MobilegeX app: app${t}"

    # send with token
    # EDGECLOUD-2640 DME panic when PlatformFindCloudlet is used on a non Samsung app
    ${error_msg}=  Run Keyword And Expect Error  *  Platform Find Cloudlet  carrier_name=${tmus_operator_name}  client_token=${fqdn.client_token}
    Should Contain  ${error_msg}  status = StatusCode.PERMISSION_DENIED
    Should Contain  ${error_msg}  details = "API Not allowed for developer: MobilegeX app: app${t}"

*** Keywords ***
Setup
    Create Flavor
    #Create Cluster	
    #Create Developer            developer_name=${samsung_developer_name}
    # ignore error since samsung app sometimes already exists
    Run Keyword and Ignore Error  Create App			developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  official_fqdn=${samsung_uri} 
    #Create App Instance         app_name=${samsung_app_name}  developer_name=${samsung_developer_name}  cloudlet_name=${samsung_cloudlet_name}  operator_org_name=${samsung_operator_name}  uri=${samsung_uri}  cluster_instance_name=autocluster

