*** Settings ***
Documentation   MasterController User Delete

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   ${mextester06_gmail_password}
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

*** Test Cases ***
# ECQ-3267
MC - Delete a user without a user name
   [Documentation]
   ...  - delete a user without a user name
   ...  - verify the correct error message is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"User Name not specified"}')   Delete User    token=${userToken}     use_defaults=${False}

# ECQ-3268
MC - Delete a user without a token
   [Documentation]
   ...  - delete a user without a token
   ...  - verify the correct error message is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Delete User     username=myuser     use_defaults=${False}

# ECQ-3269
MC - Delete a user with an empty token
   [Documentation]
   ...  - delete a user with an empty token
   ...  - verify the correct error message is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Delete User    username=myuser      token=${EMPTY}      use_defaults=${False}

# ECQ-3270
MC - Delete a user with a bad token
   [Documentation]
   ...  - delete a user with a bad token
   ...  - verify the correct error message is returned

   Run Keyword and Expect Error  ('code=401', 'error={"message":"Invalid or expired jwt"}')  Delete User    username=myuser      token=thisisabadtoken      use_defaults=${False}

# ECQ-3271
MC - Delete a user with an expired token
   [Documentation]
   ...  - delete a user with an expired token
   ...  - verify the correct error message is returned

   Run Keyword and Expect Error  ('code=401', 'error={"message":"Invalid or expired jwt"}')  Delete User    username=myuser       token=${expToken}      use_defaults=${False}
	
*** Keywords ***
Setup
   Login  username=${admin_manager_username}  password=${admin_manager_password}
   #Create User  username=myuser   password=${password}   email_address=xy@xy.com
   #Unlock User  username=myuser
   #${userToken}=  Login  username=myuser  password=${password}
   ${userToken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   Set Suite Variable  ${userToken}
	
