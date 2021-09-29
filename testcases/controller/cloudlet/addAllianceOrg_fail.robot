*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         String

Test Setup      Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${region}  US

*** Test Cases ***
# ECQ-3964
AddAllianceOrg - add alliance orgs to unknown cloudlet shall return error
   [Documentation]
   ...  - send AddAllianceOrg to add orgs to unknown cloudlet
   ...  - verify proper error is returned

   [Tags]  AllianceOrg

   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Alliance Org  region=${region}  cloudlet_name=xxx  operator_org_name=dmuus  alliance_org_name=dmuus
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"xxx\\\\"} not found"}')

   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Alliance Org  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=dmuusx  alliance_org_name=dmuus
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"dmuusx\\\\",\\\\"name\\\\":\\\\"tmocloud-1\\\\"} not found"}')

# ECQ-3965
AddAllianceOrg - add unknown alliance orgs to cloudlet shall return error
   [Documentation]
   ...  - send AddAllianceOrg to add unknown orgs
   ...  - verify proper error is returned

   [Tags]  AllianceOrg

   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Alliance Org  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=dmuus  alliance_org_name=dmuusx
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Cloudlet key {\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"xxx\\\\"} not found"}')

# ECQ-3966
AddAllianceOrg - add developer alliance orgs to cloudlet shall return error
   [Documentation]
   ...  - send AddAllianceOrg to add developer org
   ...  - verify proper error is returned

   [Tags]  AllianceOrg

   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Alliance Org  region=${region}  cloudlet_name=tmocloud-1  operator_org_name=dmuus  alliance_org_name=automation_dev_org
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Operation only allowed for organizations of type operator"}')

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

