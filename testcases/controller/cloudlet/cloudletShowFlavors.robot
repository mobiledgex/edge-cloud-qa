*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
Library  Collections

Test Setup      Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${region}  EU
${cloudlet}=  ${cloudlet_name_crm}
${cloudlet_org}=  ${operator_name_crm}

*** Test Cases ***
# ECQ-3611
ShowFlavorsForCloudlet - shall be able to get all supported flavors for a cloudlet
   [Documentation]
   ...  - Get all flavors in the region 
   ...  - call FindFlavorMatch to see which flavors are supported on a cloudlet
   ...  - call ShowFlavorsForCloudlet
   ...  - verify it returns only the flavors supported from FindFlavorMatch

   @{flavors}=  Show Flavors  region=${region}  token=${token}  use_defaults=${False}

   @{passlist}=  Create List
   @{faillist}=  Create List
   
   FOR  ${f}  IN  @{flavors}
      ${msg}=  Run Keyword and Ignore Error  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=${f['data']['key']['name']} 

      IF  '${msg[0]}' == 'PASS'
          Append To List  ${passlist}  ${f['data']['key']['name']} 
      ELSE
          Append To List  ${faillist}  ${f['data']['key']['name']}
      END
   END

   @{supported}=  Create List
   @{show}=  Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}
   FOR  ${sf}  IN  @{show}
      Append To List  ${supported}  ${sf['data']['name']}
   END

   Sort List  ${passlist}
   Sort List  ${faillist}
   Sort List  ${supported}

   Lists Should Be Equal  ${supported}  ${passlist}

   List Should Contain Value  ${supported}  ${flavor_name_good}
   List Should Contain Value  ${supported}  ${gpu_flavor_name_good}

   IF  ${platform} == 11    # VCD
      Length Should Be  ${faillist}  0  # VCD supports all flavors
      List Should Contain Value   ${supported}  ${gpu_flavor_name_bad}
      List Should Contain Value   ${supported}  ${large_flavor_name_bad}
   ELSE
      List Should Not Contain Value   ${supported}  ${gpu_flavor_name_bad}
      List Should Not Contain Value   ${supported}  ${large_flavor_name_bad}
   END

# ECQ-3612
ShowFlavorsForCloudlet - OperatorManager shall be able to show flavors for cloudlet
   [Documentation]
   ...  - assign user to org as OperatorManager
   ...  - do FindFlavorMatch and ShowFlavorsFor
   ...  - verify they both work

   [Setup]  Userrole Setup

   ${adduser}=   Adduser Role   orgname=${cloudlet_org}   username=${op_manager_user_automation}   role=OperatorManager    token=${token}     use_defaults=${False}

   ${match}=  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=automation_api_flavor  token=${tokenop_manager}
   Should Be True  len('${match['flavor_name']}') > 0

   ${flavors}=  Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  token=${tokenop_manager}
   Should Be True  len(@{flavors}) > 0

# ECQ-3613
ShowFlavorsForCloudlet - OperatorContributor shall be able to show flavors for cloudlet
   [Documentation]
   ...  - assign user to org as OperatorContributor
   ...  - do FindFlavorMatch and ShowFlavorsFor
   ...  - verify they both work

   [Setup]  Userrole Setup

   ${adduser}=   Adduser Role   orgname=${cloudlet_org}   username=${op_manager_user_automation}   role=OperatorContributor    token=${token}     use_defaults=${False}

   ${match}=  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=automation_api_flavor  token=${tokenop_manager}
   Should Be True  len('${match['flavor_name']}') > 0

   ${flavors}=  Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  token=${tokenop_manager}
   Should Be True  len(@{flavors}) > 0

# ECQ-3614
ShowFlavorsForCloudlet - OperatorViewer shall be able to show flavors for cloudlet
   [Documentation]
   ...  - assign user to org as OperatorViewer
   ...  - do FindFlavorMatch and ShowFlavorsFor
   ...  - verify they both work

   [Setup]  Userrole Setup

   ${adduser}=   Adduser Role   orgname=${cloudlet_org}   username=${op_manager_user_automation}   role=OperatorViewer    token=${token}     use_defaults=${False}

   ${match}=  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=automation_api_flavor  token=${tokenop_manager}
   Should Be True  len('${match['flavor_name']}') > 0

   ${flavors}=  Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  token=${tokenop_manager}
   Should Be True  len(@{flavors}) > 0

# ECQ-3615
ShowFlavorsForCloudlet - DeveloperManager shall not be able to show flavors for cloudlet
   [Documentation]
   ...  - assign user to org as DeveloperManager
   ...  - do FindFlavorMatch and ShowFlavorsFor
   ...  - verify error

   [Setup]  Userrole Setup

   ${adduser}=   Adduser Role   orgname=${developer_org_name_automation}   username=${op_manager_user_automation}   role=DeveloperManager    token=${token}     use_defaults=${False}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=automation_api_flavor  token=${tokenop_manager}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')    Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  token=${tokenop_manager}

# ECQ-3616
ShowFlavorsForCloudlet - DeveloperContributor shall not be able to show flavors for cloudlet
   [Documentation]
   ...  - assign user to org as DeveloperContributor
   ...  - do FindFlavorMatch and ShowFlavorsFor
   ...  - verify error

   [Setup]  Userrole Setup

   ${adduser}=   Adduser Role   orgname=${developer_org_name_automation}   username=${op_manager_user_automation}   role=DeveloperContributor    token=${token}     use_defaults=${False}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=automation_api_flavor  token=${tokenop_manager}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')    Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  token=${tokenop_manager}

# ECQ-3617
ShowFlavorsForCloudlet - DeveloperViewer shall not be able to show flavors for cloudlet
   [Documentation]
   ...  - assign user to org as DeveloperViewer
   ...  - do FindFlavorMatch and ShowFlavorsFor
   ...  - verify error

   [Setup]  Userrole Setup

   ${adduser}=   Adduser Role   orgname=${developer_org_name_automation}   username=${op_manager_user_automation}   role=DeveloperViewer   token=${token}     use_defaults=${False}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Find Flavor Match  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  flavor_name=automation_api_flavor  token=${tokenop_manager}

   Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')    Show Flavors For Cloudlet  region=${region}  cloudlet_name=${cloudlet}  operator_org_name=${cloudlet_org}  token=${tokenop_manager}

** Keywords **
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${c}=  Show Cloudlets  region=${region}  cloudlet_name=${cloudlet}  token=${token}  use_defaults=${False}
   ${platform}=  Set Variable  ${c[0]['data']['platform_type']}

   ${flavor_good}=      Create Flavor  region=${region}
   ${gpu_flavor_good}=       Create Flavor  region=${region}  flavor_name=${flavor_good['data']['key']['name']}1  disk=80  optional_resources=gpu=pci:1
   ${gpu_flavor_bad}=  Create Flavor  region=${region}  flavor_name=${flavor_good['data']['key']['name']}2  disk=80  optional_resources=gpu=xgpu:1
   ${large_flavor_bad}=     Create Flavor  region=${region}  flavor_name=${flavor_good['data']['key']['name']}3  disk=8000

   ${flavor_name_good}=       Set Variable  ${flavor_good['data']['key']['name']}
   ${gpu_flavor_name_good}=   Set Variable  ${gpu_flavor_good['data']['key']['name']}
   ${gpu_flavor_name_bad}=    Set Variable  ${gpu_flavor_bad['data']['key']['name']}
   ${large_flavor_name_bad}=    Set Variable  ${large_flavor_bad['data']['key']['name']}

   Set Suite Variable  ${platform}

   Set Suite Variable  ${flavor_name_good}
   Set Suite Variable  ${gpu_flavor_name_good}
   Set Suite Variable  ${gpu_flavor_name_bad}
   Set Suite Variable  ${large_flavor_name_bad}

Userrole Setup 
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${tokendev_manager}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${tokendev_contributor}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${tokendev_viewer}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   ${tokenop_manager}=  Login  username=${op_manager_user_automation}  password=${dev_manager_password_automation}
   ${tokenop_contributor}=  Login  username=${op_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${tokenop_viewer}=  Login  username=${op_viewer_user_automation}  password=${dev_viewer_password_automation}

   Set Suite Variable  ${tokendev_manager}
   Set Suite Variable  ${tokendev_contributor}
   Set Suite Variable  ${tokendev_viewer}

   Set Suite Variable  ${tokenop_manager}
   Set Suite Variable  ${tokenop_contributor}
   Set Suite Variable  ${tokenop_viewer}

 
