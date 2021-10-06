*** Settings ***
Documentation  Resource Usage Userrole Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout    10 min

*** Variables ***
${region}=  US

${operator_name_openstack}  GDDT
${cloudlet_name_openstack}  automationHawkinsCloudlet

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3327
DeveloperManager shall not be able to fetch cloudlet resource usage/metrics data
   [Documentation]
   ...  - Controller returns 403 forbidden when getresourceusage/getresourcequotaprops is executed
   ...  - Controller returns 403 forbidden when metrics cloudletusage is executed

   ${tokendev}=  Login  username=dev_manager_automation  password=${dev_manager_password_automation}

   Verify Resource Usage  ${tokendev}  403 Forbidden

# ECQ-3328
DeveloperContributor shall not be able to fetch cloudlet resource usage/metrics data
   [Documentation]
   ...  - Controller returns 403 forbidden when getresourceusage/getresourcequotaprops is executed
   ...  - Controller returns 403 forbidden when metrics cloudletusage is executed

   ${tokendev}=  Login  username=dev_contributor_automation  password=${dev_contributor_password_automation}

   Verify Resource Usage  ${tokendev}  403 Forbidden

# ECQ-3329
DeveloperViewer shall not be able to fetch cloudlet resource usage/metrics data
   [Documentation]
   ...  - Controller returns 403 forbidden when getresourceusage/getresourcequotaprops is executed
   ...  - Controller returns 403 forbidden when metrics cloudletusage is executed

   ${tokendev}=  Login  username=dev_viewer_automation  password=${dev_viewer_password_automation}

   Verify Resource Usage  ${tokendev}  403 Forbidden

# ECQ-3330
OperatorManager shall be able to fetch cloudlet resource usage/metrics data
   [Documentation]
   ...  - Create user with role OperatorManager
   ...  - Controller returns cloudlet resource usage details when getresourceusage/getresourcequotaprops is executed
   ...  - Controller returns when cloudletusage metrics

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorManager
   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}

   Verify Resource Usage  ${tokenop}  200 OK

# ECQ-3331
OperatorContributor shall be able to fetch cloudlet resource usage/metrics data
   [Documentation]
   ...  - Create user with role OperatorContributor
   ...  - Controller returns cloudlet resource usage details when getresourceusage/getresourcequotaprops is executed
   ...  - Controller returns when cloudletusage metrics

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorContributor
   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}

   Verify Resource Usage  ${tokenop}  200 OK

# ECQ-3332
OperatorViewer shall be able to fetch cloudlet resource usage/metrics data
   [Documentation]
   ...  - Create user with role OperatorViewer
   ...  - Controller returns cloudlet resource usage details when getresourceusage/getresourcequotaprops is executed
   ...  - Controller returns when cloudletusage metrics

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorViewer
   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}

   Verify Resource Usage  ${tokenop}  200 OK

# ECQ-3333
User of Operator A shall not be able to fetch cloudlet resource usage/metrics data of a different Operator Org
   [Documentation]
   ...  - Create user with role OperatorManager belonging to Operator A
   ...  - Controller returns 403 forbidden when getresourceusage/getresourcequotaprops is executed for a different operator
   ...  - Controller returns 403 forbidden when metrics cloudletusage is executed for a different operator

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorManager
   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}

   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')   Get Resource Usage  region=US  operator_org_name=packet  cloudlet_name=packet-qaregression  token=${tokenop}

   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')   Get ResourceQuota Props  region=US  operator_org_name=packet  platform_type=PlatformTypeOpenstack  token=${tokenop}

   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')   Get CloudletUsage Metrics  region=US  operator_org_name=packet  cloudlet_name=packet-qaregression  selector=flavorusage  limit=2  token=${tokenop}
 
*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${developer_name}=  Get Default Developer Name
   ${org_name}=  Get Default Organization Name

   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${org_name}

Verify Resource Usage
   [Arguments]   ${usertoken}  ${code}

   Run Keyword If  '${code}' == '200 OK'   Get Details  ${usertoken}
   ...  ELSE  Get Error  ${usertoken}

Get Details
   [Arguments]   ${optoken}

   ${resourceusage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${optoken}
   Should Not Be EMPTY  ${resourceusage}

   ${resourcequotaprops}=  Get ResourceQuota Props  region=${region}  operator_org_name=${operator_name_openstack}  platform_type=PlatformTypeOpenstack  token=${optoken}
   Should Not Be EMPTY  ${resourcequotaprops}

   ${metrics}=  Get CloudletUsage Metrics  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  selector=flavorusage  limit=2  token=${optoken}
   Should Not Be EMPTY  ${metrics}

Get Error
   [Arguments]   ${devtoken}

   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')   Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${devtoken}
   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')   Get ResourceQuota Props  region=${region}  operator_org_name=${operator_name_openstack}  platform_type=PlatformTypeOpenstack  token=${devtoken}
   Run Keyword and Expect Error   ('code=403', 'error={"message":"Forbidden"}')   Get CloudletUsage Metrics  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  selector=flavorusage  limit=2  token=${devtoken}
