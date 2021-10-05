*** Settings ***
Documentation   CreateAppInst with same cluster

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${region}=  US

*** Test Cases ***
# ECQ-4002
CreateAppInst - error shall be received when creating 2 appinst with differnt version but same TCP port on same dedicated clusterinst
    [Documentation]
    ...  - create a dedicated cluster inst
    ...  - create an 2 apps with same name but with version=1.0 and version=2.0 and same TCP port numbers
    ...  - create an app instance with version=1.0
    ...  - create an app instance with version=2.0
    ...  - verify error is received

    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    ${app}=  Create App  region=${region}  app_version=1.0  access_ports=tcp:1  deployment=docker
    Create App Instance  region=${region}  app_version=1.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_version=2.0  access_ports=tcp:1  deployment=docker
    ${error1}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}2  app_version=2.0  access_ports=tcp:1,tcp:6  deployment=docker
    ${error2}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}3  app_version=2.0  access_ports=udp:1,tcp:1  deployment=docker
    ${error3}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Port 1 is already in use on the cluster"}')
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Port 1 is already in use on the cluster"}')
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"Port 1 is already in use on the cluster"}')

# ECQ-4003
CreateAppInst - error shall be received when creating 2 appinst with differnt version but same UDP port on same dedicated clusterinst
    [Documentation]
    ...  - create a dedicated cluster inst
    ...  - create an 2 apps with same name but with version=1.0 and version=2.0 and same UDP port numbers
    ...  - create an app instance with version=1.0
    ...  - create an app instance with version=2.0
    ...  - verify error is received

    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    ${app}=  Create App  region=${region}  app_version=1.0  access_ports=udp:1  deployment=docker
    Create App Instance  region=${region}  app_version=1.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_version=2.0  access_ports=udp:1  deployment=docker
    ${error1}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}2  app_version=2.0  access_ports=udp:1,udp:4  deployment=docker
    ${error2}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}1  app_version=2.0  access_ports=udp:1,tcp:4  deployment=docker
    ${error3}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Port 1 is already in use on the cluster"}')
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Port 1 is already in use on the cluster"}')
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"Port 1 is already in use on the cluster"}')

# ECQ-4004
CreateAppInst - error shall be received when creating 2 appinst with differnt version but same TCP port range on same dedicated clusterinst
    [Documentation]
    ...  - create a dedicated cluster inst
    ...  - create an 2 apps with same name but with version=1.0 and version=2.0 and same TCP port ranges
    ...  - create an app instance with version=1.0
    ...  - create an app instance with version=2.0
    ...  - verify error is received

    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    ${app}=  Create App  region=${region}  app_version=1.0  access_ports=tcp:1-10  deployment=docker
    Create App Instance  region=${region}  app_version=1.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_version=2.0  access_ports=tcp:2  deployment=docker
    ${error1}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}2  app_version=2.0  access_ports=tcp:1-10  deployment=docker
    ${error2}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}3  app_version=2.0  access_ports=tcp:2-9  deployment=docker
    ${error3}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}4  app_version=2.0  access_ports=tcp:10-11  deployment=docker
    ${error4}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Port 2 is already in use on the cluster"}')
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Port range 1-10 overlaps with ports in use on the cluster"}')
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"Port range 2-9 overlaps with ports in use on the cluster"}')
    Should Be Equal  ${error4}  ('code=400', 'error={"message":"Port range 10-11 overlaps with ports in use on the cluster"}')

# ECQ-4005
CreateAppInst - error shall be received when creating 2 appinst with differnt version but same UDP port range on same dedicated clusterinst
    [Documentation]
    ...  - create a dedicated cluster inst
    ...  - create an 2 apps with same name but with version=1.0 and version=2.0 and same UDP port ranges
    ...  - create an app instance with version=1.0
    ...  - create an app instance with version=2.0
    ...  - verify error is received

    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    ${app}=  Create App  region=${region}  app_version=1.0  access_ports=udp:1-10  deployment=docker
    Create App Instance  region=${region}  app_version=1.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_version=2.0  access_ports=udp:2  deployment=docker
    ${error1}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}2  app_version=2.0  access_ports=udp:1-10  deployment=docker
    ${error2}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}3  app_version=2.0  access_ports=udp:2-9  deployment=docker
    ${error3}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Create App  region=${region}  app_name=${app['data']['key']['name']}4  app_version=2.0  access_ports=udp:10-11  deployment=docker
    ${error4}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_version=2.0  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=${cluster['data']['key']['cluster_key']['name']}

    Should Be Equal  ${error1}  ('code=400', 'error={"message":"Port 2 is already in use on the cluster"}')
    Should Be Equal  ${error2}  ('code=400', 'error={"message":"Port range 1-10 overlaps with ports in use on the cluster"}')
    Should Be Equal  ${error3}  ('code=400', 'error={"message":"Port range 2-9 overlaps with ports in use on the cluster"}')
    Should Be Equal  ${error4}  ('code=400', 'error={"message":"Port range 10-11 overlaps with ports in use on the cluster"}')

*** Keywords ***
Setup
    Create Flavor  region=${region}

Teardown
    Cleanup provisioning
