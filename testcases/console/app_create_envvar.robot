*** Settings ***
Documentation   Create new App
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX
${config}      - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]
${config_helm}      nfs:${\n}${SPACE*2}path: /share${\n}${SPACE*2}server: [[ .Deployment.ClusterIp ]]${\n}storageClass:${\n}${SPACE*2}name: standard${\n}${SPACE*2}defaultClass: true
${wait}  200


*** Test Cases ***
Web UI - User shall be able to create a New Kubernetes App for EU Region with Environment Variables
    [Documentation]
    ...  Create a new EU Kubernetes App with Environment Variables
    ...  Verify Kubernetes App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=kubernetes  access_ports=tcp:2015  envvar=${config}

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['configs'][0]['config'].replace('\r\n', '\n')}  ${config.replace('\r\n', '\n')}
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist


Web UI - User shall be able to create a New Docker App for EU Region with Environment Variables
    [Documentation]
    ...  Create a new EU Docker App with Environment Variables
    ...  Verify Docker App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=docker  access_ports=tcp:2015  envvar=${config}

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
        Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['configs'][0]['config'].replace('\r\n', '\n')}  ${config.replace('\r\n', '\n')}
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

Web UI - User shall be able to create a New Helm App for EU Region with Environment Variables
    [Documentation]
    ...  Create a new EU Helm App with Environment Variables
    ...  Verify Helm App shows in list

    Add New App  region=EU  app_name=${app_name}  developer_name=${developer_name}  deployment_type=helm  access_ports=tcp:2015  envvar=${config_helm}

    App Should Exist  change_rows_per_page=True

    @{app_details}=    Show Apps  region=EU

    FOR  ${row}  IN  @{app_details}
       Run Keyword If  '${row['data']['key']['name']}' == '${app_name}'  Should Be Equal  ${row['data']['configs'][0]['config'].replace('\r\n', '\n')}  ${config_helm.replace('\r\n', '\n')}
    END

    MexConsole.Delete App  click_previous_page=off

    App Should Not Exist

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${app_name}=  Get Default App Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Apps
    Set Suite Variable  ${token}
    Set Suite Variable  ${app_name}

Teardown
    Close Browser
