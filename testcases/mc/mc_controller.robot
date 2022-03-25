*** Settings ***
Documentation   MasterController controller

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
	
#Suite Setup	 Setup
Test Teardown    Cleanup provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4410
MC - Admin shall be able to see all controller info
    [Documentation]
    ...  - do controller show as admin 
    ...  - verify it returns all info

    Login  username=${admin_manager_username}  password=${admin_manager_password}
    
    ${info}=  Show Controller

    Should Be Equal  ${info[0]['Region']}         US
    Should Be Equal  ${info[0]['DnsRegion']}      us
    Should Be Equal  ${info[0]['Address']}        mexplat-qa-us.ctrl.mobiledgex.net:55001 
    Should Be Equal  ${info[0]['InfluxDB']}       https://us-qa.influxdb.mobiledgex.net:8086
    Should Not Contain  ${info[0]}  NotifyAddr
    Should Not Contain  ${info[0]}  ThanosMetrics
    Should Be True  len('${info[0]['CreatedAt']}') > 1
    Should Be True  len('${info[0]['UpdatedAt']}') > 1

    Should Be Equal  ${info[1]['Region']}         EU
    Should Be Equal  ${info[1]['DnsRegion']}      eu
    Should Be Equal  ${info[1]['Address']}        mexplat-qa-eu.ctrl.mobiledgex.net:55001
    Should Be Equal  ${info[1]['InfluxDB']}       https://eu-qa.influxdb.mobiledgex.net:8086
    Should Not Contain  ${info[0]}  NotifyAddr
    Should Not Contain  ${info[0]}  ThanosMetrics
    Should Be True  len('${info[1]['CreatedAt']}') > 1
    Should Be True  len('${info[1]['UpdatedAt']}') > 1
 
    Length Should Be  ${info}  2

# ECQ-4411
MC - Non-admin shall not be able to see all controller info
    [Documentation]
    ...  - do controller show as all non-admin types of operator and developer
    ...  - verify it returns only region

    # EDGECLOUD-6277 controller show for nonadmin should only return the region json tag  - closed

    [Template]  Non-admin shall show region only

    ${op_manager_user_automation}      ${op_manager_password_automation}
    ${op_contributor_user_automation}  ${op_contributor_password_automation}
    ${op_viewer_user_automation}       ${op_viewer_password_automation}

    ${dev_manager_user_automation}      ${dev_manager_password_automation}
    ${dev_contributor_user_automation}  ${dev_contributor_password_automation}
    ${dev_viewer_user_automation}       ${dev_viewer_password_automation}

    ${op_manager_user_automation}      ${op_manager_password_automation}  address=mexplat-qa-us.ctrl.mobiledgex.net:55001
    ${op_contributor_user_automation}  ${op_contributor_password_automation}  address=mexplat-qa-us.ctrl.mobiledgex.net:55001
    ${op_viewer_user_automation}       ${op_viewer_password_automation}  address=mexplat-qa-us.ctrl.mobiledgex.net:55001

    ${dev_manager_user_automation}      ${dev_manager_password_automation}  address=mexplat-qa-us.ctrl.mobiledgex.net:55001
    ${dev_contributor_user_automation}  ${dev_contributor_password_automation}  address=mexplat-qa-us.ctrl.mobiledgex.net:55001
    ${dev_viewer_user_automation}       ${dev_viewer_password_automation}  address=mexplat-qa-us.ctrl.mobiledgex.net:55001

    ${op_manager_user_automation}      ${op_manager_password_automation}  influx=https://us-qa.influxdb.mobiledgex.net:8086
    ${op_contributor_user_automation}  ${op_contributor_password_automation}  influx=https://us-qa.influxdb.mobiledgex.net:8086
    ${op_viewer_user_automation}       ${op_viewer_password_automation}  influx=https://us-qa.influxdb.mobiledgex.net:8086

    ${dev_manager_user_automation}      ${dev_manager_password_automation}  influx=https://us-qa.influxdb.mobiledgex.net:8086
    ${dev_contributor_user_automation}  ${dev_contributor_password_automation}  influx=https://us-qa.influxdb.mobiledgex.net:8086
    ${dev_viewer_user_automation}       ${dev_viewer_password_automation}  influx=https://us-qa.influxdb.mobiledgex.net:8086

*** Keywords ***
Non-admin shall show region only
    [Arguments]  ${username}  ${password}  ${address}=${None}  ${influx}=${None}

    Login  username=${username}  password=${password}

    ${info}=  Show Controller  controller_address=${address}  influxdb_address=${influx}

    Should Be Equal  ${info[0]['Region']}         US
    Should Be Equal  ${info[1]['Region']}         EU

    Should Not Contain  ${info[0]}  DnsRegion
    Should Not Contain  ${info[0]}  Address
    Should Not Contain  ${info[0]}  InfluxDB
    Should Not Contain  ${info[0]}  NotifyAddr
    Should Not Contain  ${info[0]}  ThanosMetrics

    Should Not Contain  ${info[0]}  DnsRegion
    Should Not Contain  ${info[0]}  Address
    Should Not Contain  ${info[0]}  InfluxDB
    Should Not Contain  ${info[0]}  NotifyAddr
    Should Not Contain  ${info[0]}  ThanosMetrics

    Length Should Be  ${info}  2


