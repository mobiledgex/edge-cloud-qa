*** Settings ***
Documentation  CreateAutoProvPolicy failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
CreateAutoProvPolicy - create without region shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy without region
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  token=${token}  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"no region specified"}

CreateAutoProvPolicy - create without parameters shall return error
   [Documentation] 
   ...  send CreateAutoProvPolicy with region only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}

CreateAutoProvPolicy - create without organization shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy without organization name 
   ...  verify proper error is received

   # policy name only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}

   # deploy_client_count only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  deploy_client_count=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}

   # deploy_interval_count only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  deploy_interval_count=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}

   # min_active_instances only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  min_active_instances=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}
                        
   # max_instances only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  max_instances=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}

   # triggertime only
   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  cloudlet_list=${cloudletlist}  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid organization, name cannot be empty"}

CreateAutoProvPolicy - create with organization only shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with organization name only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  developer_org_name=MobiledgeX  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Policy name cannot be empty"}

CreateAutoProvPolicy - create with policy/organization name only shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with policy/organization name only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}  {"message":"One of deploy client count and minimum active instances must be specified"} 

CreateAutoProvPolicy - create with policy/organization name and min_active_instances only shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with policy/organization name and min_active_instances only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=1  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}  {"message":"Minimum Active Instances cannot be larger than the number of Cloudlets"}

CreateAutoProvPolicy - create with policy/organization name and max_instances only shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with policy/organization name and max_instances only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  max_instances=1  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}  {"message":"One of deploy client count and minimum active instances must be specified"}
	
CreateAutoProvPolicy - create with policy/organization name and min_active_instances/max_instances only shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with policy/organization name and min_active_instances/max_instances only
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=1  max_instances=2  use_defaults=False

   Should Contain   ${error}   400
   Should Contain   ${error}  {"message":"Minimum Active Instances cannot be larger than the number of Cloudlets"}

CreateAutoProvPolicy - create with min_active_instances >= max_instances shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with minnodes >= maxnodes
   ...  verify proper error is received
  
   # max < min
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=2  max_instances=1  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Minimum active instances cannot be larger than Maximum Instances"}

CreateAutoProvPolicy - create with min_active_instances > numcloudlets shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with min_active_instances > numcloudlets
   ...  verify proper error is received

   # max < min
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=2  max_instances=0  cloudlet_list=[]  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Minimum Active Instances cannot be larger than the number of Cloudlets"}

   # max=0
   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=2  max_instances=0  use_defaults=False  cloudlet_list=${cloudletlist}
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Minimum Active Instances cannot be larger than the number of Cloudlets"}

CreateAutoProvPolicy - create with invalid min_active_instances shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with invalid min_active_instances
   ...  verify proper error is received

   #minnodes=-1
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=-1  max_instances=2
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data

   #minnodes=x
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=x  max_instances=2  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data

CreateAutoProvPolicy - create with invalid max_instances shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with invalid max_instances 
   ...  verify proper error is received

   #maxnodes=-1
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=1  max_instances=-1  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data

   #maxnodes=x
   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=2  max_instances=x  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data

CreateAutoProvPolicy - create with same name shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy twice for same policy 
   ...  verify proper error is received

   ${pname}=  Get Default Auto Provisioning Policy Name

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-1  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   Create Auto Provisioning Policy  region=US  developer_org_name=MobiledgeX  policy_name=${pname}2  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}

   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  policy_name=${pname}2  developer_org_name=MobiledgeX  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Policy key {\\\\"organization\\\\":\\\\"MobiledgeX\\\\",\\\\"name\\\\":\\\\"${pname}2\\\\"} already exists"}

CreateAutoProvPolicy - create with unknown organization name shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with invalid org name 
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  token=${token}  policy_name=${pname}  developer_org_name=xxxxxx  min_active_instances=1  max_instances=2  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  message=org xxxxxx not found

CreateAutoProvPolicy - create with unknown cloudlet shall return error
   [Documentation]
   ...  send CreateAutoProvPolicy with unkown cloudlet
   ...  verify proper error is received

   &{cloudlet1}=  Create Dictionary  cloudlet_name=tmocloud-xxxxx  cloudlet_org_name=tmus  latitude=1  longitude=1
   @{cloudletlist}=  Create List  ${cloudlet1}

   ${error}=  Run Keyword And Expect Error  *   Create Auto Provisioning Policy  region=US  policy_name=${pname}  developer_org_name=MobiledgeX  min_active_instances=1  max_instances=1  cloudlet_list=${cloudletlist}
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Cloudlet key {\\\\"organization\\\\":\\\\"tmus\\\\",\\\\"name\\\\":\\\\"tmocloud-xxxxx\\\\"} not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   ${pname}=  Get Default Auto Provisioning Policy Name
   Set Suite Variable  ${token}
   Set Suite Variable  ${pname}

