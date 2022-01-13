*** Settings ***
Documentation    Federatorzone userroles tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${selfoperator}  packet
${region}  EU
${selfcountrycode}  DE

*** Test Cases ***
# ECQ-4224
OperatorManager of org A shall not be able to create/view/delete/register/deregister federatorzone of Operator Org B
    [Documentation]
    ...  Login as OperatorManager of org A
    ...  Create/View/Delete federatorzone of Operator Org B
    ...  Controller throws 403 forbidden

    @{cloudlets}=  Create List  ${cloudlet_name}
    @{zones}=  Create List  zone1

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=tmus  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}

    Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False} 

    ${federatorzone_show}=  Show FederatorZone  operatorid=${selfoperator}  zoneid=${federator_zone}  token=${op1_token}
    Should Be Empty  ${federatorzone_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Register FederatorZone  selfoperatorid=${selfoperator}  federation_name=${federation_name}  zones=${zones}  use_defaults=${False}  token=${op1_token}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Deregister FederatorZone  selfoperatorid=${selfoperator}  federation_name=${federation_name}  zones=${zones}  use_defaults=${False}  token=${op1_token}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}

# ECQ-4225
OperatorContributor shall be able to create/view/delete federatorzone
    [Documentation]
    ...  Login as OperatorContributor
    ...  Create/View/Delete federatorzone

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword And Ignore Error  Adduser Role  username=${op_contributor_user_automation}  orgname=tmus  role=OperatorContributor  token=${super_token}
    ${op1_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

    Create FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}  auto_delete=${False}

    ${federatorzone_show}=  Show FederatorZone  operatorid=tmus  zoneid=${federator_zone}  token=${op1_token}
    Should Not Be Empty  ${federatorzone_show}

    Delete FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}

# ECQ-4226
OperatorViewer shall not be able to create/delete federatorzone
    [Documentation]
    ...  Login as OperatorViewer
    ...  Create/View/Delete federatorzone
    ...  Controller throws 403 forbidden for create/delete federatorzone
    ...  OperatorViewer is only able to view federatorzone

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword And Ignore Error  Adduser Role  username=${op_viewer_user_automation}  orgname=tmus  role=OperatorViewer  token=${super_token}
    ${op1_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}  auto_delete=${False}

    Create FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}

    ${federatorzone_show}=  Show FederatorZone  operatorid=tmus  zoneid=${federator_zone}  token=${op1_token}
    Should Not Be Empty  ${federatorzone_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}

# ECQ-4227
DeveloperManager shall not be able to create/delete/view federatorzone
    [Documentation]
    ...  Login as DeveloperManager
    ...  Create/View/Delete federatorzone
    ...  Controller throws 403 forbidden

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=tmus  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Run Keyword And Ignore Error  Adduser Role  username=${dev_manager_user_automation}  orgname=${developer_org_name_automation}  role=DeveloperManager  token=${super_token}
    ${dev1_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

     Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${dev1_token}  auto_delete=${False}

    Create FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}

    ${federatorzone_show}=  Show FederatorZone  operatorid=tmus  zoneid=${federator_zone}  token=${dev1_token}
    Should Be Empty  ${federatorzone_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete FederatorZone  operatorid=tmus  countrycode=${selfcountrycode}  zoneid=${federator_zone}  use_defaults=${False}  token=${dev1_token}


*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federator_zone}=  Get Default Federator Zone
    ${cloudlet_name}=  Get Default Cloudlet Name
    ${federation_name}=  Get Default Federation Name

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${federator_zone}
    Set Suite Variable  ${cloudlet_name}
    Set Suite Variable  ${federation_name}
