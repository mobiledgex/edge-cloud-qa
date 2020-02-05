*** Settings ***
Documentation  Show/Create/DeleteCloudletPool for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  mextester06123

${region}=  US

*** Test Cases ***
CreatePrivacyPolicy - user shall get an error when creating a privacy policy 
   [Documentation]
   ...  send CreatePrivacyPolicy with user token 
   ...  verify proper error is received 

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"code=403, message=Forbidden"}')  Create Privacy Policy  token=${user_token}  region=${region}  rule_list=${rulelist}

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Verify Email  email_address=${emailepoch}
   Unlock User

   ${userToken}=  Login  username=${epochusername}  password=${password}

   Set Suite Variable  ${userToken}
