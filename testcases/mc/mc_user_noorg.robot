*** Settings ***
Documentation   MasterController User Operation with no org
	
Library	 MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
	
*** Test Cases ***
# ECQ-4408
MC - User without an org shall not be able to Show
    [Documentation]
    ...  - create a user with no org assigned
    ...  - do various mc operations
    ...  - verify forbidden is returnedv

    [Template]  Do Operation

    Show Events  region=US
    Show Apps  region=US
    Show App Instances  region=US
    Show Cloudlets  region=US
    Show User
    Show Cluster Instances  region=US
    Show Cloudlet Pool  region=US
    Show Trust Policy  region=US
    Show Trust Policy Exception  region=US
    Show Network  region=US
    Show Alert Receivers
    Show Alert Policy  region=US
    Show Reporter
    Show Report  organization=x
    Show Federator
    Show Federation
    
*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch

   ${emailepoch}=  Catenate  SEPARATOR=  user  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  user  ${epoch}
   ${adminuser}=   Catenate  SEPARATOR=  user  ${epoch}  01
   ${adminuseremail}=  Catenate  SEPARATOR=  user  +  ${epoch}  01  @gmail.com

   #Skip Verify Email   skip_verify_email=False
   Create User  username=${epochusername}   password=${op_manager_password_automation}   email_address=${emailepoch}    email_check=${False}
   Unlock User

   Login  username=${epochusername}   password=${op_manager_password_automation}

Do Operation 
    [Arguments]  ${operation}  &{args}
    Run Keyword And Expect Error  ('code=403', 'error={"message":"Forbidden"}')   ${operation}  &{args}
