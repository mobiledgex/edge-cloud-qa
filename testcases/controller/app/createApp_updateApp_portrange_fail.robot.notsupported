*** Settings ***
Documentation   CreateApp and UpdateApp port range loadbalancer fail 

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	

Library         String
	
Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${qcow_centos_image}=  https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${docker_compose_url}=  http://35.199.188.102/apps/server_ping_threaded_compose.yml

*** Test Cases ***
# ECQ-2099
CreateApp - Create shall fail for port out of range on k8s access_type=loadbalancer
    [Documentation]
    ...  create a k8s loadbalancer app with port range greater than max 
    ...  verify proper error is returned 
	
    ${error}=  Run Keyword and Expect Error  *  Create App  region=US  access_ports=tcp:23-74  deployment=kubernetes  access_type=loadbalancer
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2100
CreateApp - Create shall fail for port out of range on docker access_type=loadbalancer
    [Documentation]
    ...  create a docker loadbalancer app with port range greater than max
    ...  verify proper error is returned

    ${error}=  Run Keyword and Expect Error  *  Create App  region=US  access_ports=tcp:23-74  deployment=docker  access_type=loadbalancer
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2101
CreateApp - Create shall fail for port out of range on vm access_type=loadbalancer
    [Documentation]
    ...  create a vm loadbalancer app with port range greater than max
    ...  verify proper error is returned

    ${error}=  Run Keyword and Expect Error  *  Create App  region=US  access_ports=tcp:23-74  deployment=vm  access_type=loadbalancer  image_type=ImageTypeQCOW  image_path=${qcow_centos_image}
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2102
CreateApp - Create shall fail for port out of range on helm access_type=loadbalancer
    [Documentation]
    ...  create a helm loadbalancer app with port range greater than max
    ...  verify proper error is returned

    ${error}=  Run Keyword and Expect Error  *  Create App  region=US  access_ports=tcp:23-74  deployment=helm  access_type=loadbalancer  image_type=ImageTypeHelm
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2103
UpdateApp - Update shall fail for port out of range on k8s access_type=loadbalancer
    [Documentation]
    ...  update a k8s loadbalancer app with port range greater than max
    ...  verify proper error is returned

    Create App  region=US  access_ports=tcp:1-5  deployment=kubernetes  access_type=loadbalancer

    ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:23-74
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2104
UpdateApp - Update shall fail for port out of range on docker access_type=loadbalancer
    [Documentation]
    ...  update a docker loadbalancer app with port range greater than max
    ...  verify proper error is returned

    Create App  region=US  access_ports=tcp:1-5  deployment=docker  access_type=loadbalancer  deployment_manifest=${docker_compose_url}

    ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:23-74  deployment_manifest=${docker_compose_url}
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2105
UpdateApp - Update shall fail for port out of range on vm access_type=loadbalancer
    [Documentation]
    ...  update a vm loadbalancer app with port range greater than max
    ...  verify proper error is returned

    Create App  region=US  access_ports=tcp:1-5  deployment=vm  access_type=loadbalancer  image_type=ImageTypeQCOW  image_path=${qcow_centos_image}

    ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:23-74
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

# ECQ-2106
UpdateApp - Update shall fail for port out of range on helm access_type=loadbalancer
    [Documentation]
    ...  update a helm loadbalancer app with port range greater than max
    ...  verify proper error is returned

    Create App  region=US  access_ports=tcp:1-5  deployment=helm  access_type=loadbalancer  image_type=ImageTypeHelm

    ${error}=  Run Keyword and Expect Error  *  Update App  region=US  access_ports=tcp:23-74
    Should Be Equal  ${error}  ('code=400', 'error={"message":"Port range greater than max of 50 for load balanced application"}')

*** Keywords ***
Setup
    Create Flavor  region=US
