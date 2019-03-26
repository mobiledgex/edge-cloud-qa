*** Settings ***
Documentation  VerifyLocation - various cookie erors

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables       shared_variables.py

*** Variables ***
${carrier_name}  tmus
#${expired_cookie}  eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDIzMTQ2MTEsImlhdCI6MTU0MjIyODIxMSwia2V5Ijp7InBlZXJpcCI6IjEyNy4wLjAuMSIsImRldm5hbWUiOiJBY21lQXBwQ28iLCJhcHBuYW1lIjoic29tZWFwcGxpY2F0aW9uMiIsImFwcHZlcnMiOiIxLjAifX0.GK6G0vCzlQosft7xKyC-wBjWomKBZ8JN6JfwuP6dozP9vqYSF53VjcwP0DEnyqR2-fwNJNdK1_mCzBKT3j_hJ0Rcf4U-GnNLFURNzjkBd-3XdT8C2L_XSEctMFf6BYg4GlajcteaKX-Lb__3TfEaG4gCfVcLoi1ZUqLOkY2Q2Qs0YCPM5YUU96PtY8DHNBjXu7nld3P-DFVxQYJHN9ITVnUxTkhf7dBcbnkpFClzQGkcXwuzjj_T7qg5WTHS9kEkbGFJDMENEFD_gIaLWbhzy2GnXaOWFrzVSxONgWSnazvJxjmrshpdw6_r6D68El7RhK_S5f0M3Hhi_yoBjjEhko6FGuIp2Z8VTrRvCTL2kWgS37hdeawbBWNorQ1Mzh_zk05ZDO-i-CE-zJVX5Qk0A1dlrAI_onVNScK3ijwIT-vrlSwalVmgyrijlQiXuE6wzWMiLTH9oGbeD4c-lXlSGNLTRNWLzsCv2r56QmzKuxWysQ73yb8GxaJuPAHp8udCKHUUhpHZUcfnH-1z7_vd_X1cOEYTq4lYF4n47e71wa5bXitD7nacXOzPh5Jc1gxCP355g12LX7rz_BvZ7VYQQjJVnIlO9mNj66K9ifb9zFqBvD7u0mAqoy_zyIp7rETYjYdL8klzeD93h205JAWboKUrWgUToCNfuDGJ4MCxad8

${expired_cookie}  eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM3MDgyMzEsImlhdCI6MTU1MzYyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.fpfRGQX_BadNQkP_JHwxOspn6GzT-YCMo_xv0c-YOGqyLfHELhmohpQzQyZoSiVFe8djA6QQQlIlflsHNyVdjA
#eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM2MDgyMzEsImlhdCI6MTU1MzUyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.xjsSHCrAuHfLbSkhOESTl3lUOsvVlOF9ATWhsGW6IlfkXG6LSNF4siDwg777vqrEhfAVy_YHw4RPZQ_KOCC1iQ
#eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM3MDgyMzEsImlhdCI6MTU1MzYyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.32hMJ36vMVdrcwCttwvCyXfGA3dZ1pgNC8ELmeBFu1cJw5wZPr7BWVkUrHnC3_CNqF9eJD8g_gHZnrEB0sMY-w
#eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM3MDgyMzEsImlhdCI6MTU1MzYyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.fpfRGQX_BadNQkP_JHwxOspn6GzT-YCMo_xv0c-YOGqyLfHELhmohpQzQyZoSiVFe8djA6QQQlIlflsHNyVdjA
#eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM1MDgyMzEsImlhdCI6MTU1MzQyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.zHeVoN68Xxdah7qN0mayRRwCmSq4A2eNeD-6yh1Lwf0FZ77noCzQDAYJdo87aC-zdwCT8MPdNYBrXuGeiDC4dw
#eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM2MDgyMzEsImlhdCI6MTU1MzUyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.xjsSHCrAuHfLbSkhOESTl3lUOsvVlOF9ATWhsGW6IlfkXG6LSNF4siDwg777vqrEhfAVy_YHw4RPZQ_KOCC1iQ
#eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTM3MDgyMzEsImlhdCI6MTU1MzYyMTgzMSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjIuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTUzNjIxODMwLTExOTgxNyIsImFwcG5hbWUiOiJhcHAxNTUzNjIxODMwLTExOTgxNyIsImFwcHZlcnMiOiIxLjAiLCJraWQiOjZ9fQ.32hMJ36vMVdrcwCttwvCyXfGA3dZ1pgNC8ELmeBFu1cJw5wZPr7BWVkUrHnC3_CNqF9eJD8g_gHZnrEB0sMY-w

${missingapp_cookie}  eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDc4NTQxNzEsImlhdCI6MTU0Nzc2Nzc3MSwia2V5Ijp7InBlZXJpcCI6IjEwLjY0LjAuMSIsImRldm5hbWUiOiJkZXZlbG9wZXIxNTQ3NzY3NzY5Ljg2NjQ4MDgiLCJhcHBuYW1lIjoiYXBwMTU0Nzc2Nzc2OS44NjY0ODA4IiwiYXBwdmVycyI6IjEuMCIsImtpZCI6Nn19.cz4C_GBosdYmLwvQq2JwrSQDyc9WuWXaJhBZWFZ2wGy4msImw_LplaDMEfO7XfbMR62BSZcdHnUQpPrBKlyjIw

*** Test Cases ***
VerifyLocation - request with bad session cookie shall return app not found
    [Documentation]
    ...  send VerifyLocatoin with session cookie with an app that does not exist
    ...  verify return LOC_VERIFIED of 2KM

    [Setup]  Setup

    Register Client
    Get Token

    Cleanup provisioning   # delete provisioning so app no longer exists 	

    ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  carrier_name=andy  latitude=1  longitude=1

    ${developer_name_default}=  Get Default Developer Name
    ${app_name_default}=        Get Default App Name

    Should Contain  ${error_msg}   status = StatusCode.NOT_FOUND
    Should Contain  ${error_msg}   details = "app not found: {{${developer_name_default}} ${app_name_default} 1.0}"


VerifyLocation - request without cookie should return 'missing cookie'
    [Documentation]
    ...  Send VerifyLocation without a session cookie
    ...  verify 'missing cookie' error is received
	
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  latitude=1  longitude=1  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "VerifyCookie failed: missing cookie"

VerifyLocation - request with invalid cookie of x should return 'token contains an invalid number of segments'
   [Documentation]
   ...  Send VerifyLocation with session cookie of 'x'
   ...  verify 'token contains an invalid number of segments' error is received

   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  session_cookie=x

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "token contains an invalid number of segments"

VerifyLocation - request with invalid cookie of x.x.x should return 'illegal base64 data at input byte 1' with invalid cookie
   [Documentation]
   ...  Send VerifyLocation with session cookie of 'x.x.x'
   ...  verify 'illegal base64 data at input byte 1' error is received

   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  session_cookie=x.x.x

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "illegal base64 data at input byte 1"

VerifyLocation - request with truncated cookie should return 'VerifyCookie failed: Invalid cookie, no key'
   [Documentation]
   ...  Send VerifyLocation with parital session cookie
   ...  verify 'VerifyCookie failed: Invalid cookie, no key' error is received
	
   #EDGECLOUD-338 - DME crashes when sending FindCloudlet with invalid session cookie  - fixed
   ${error_msg}=  Run Keyword And Expect Error  *  VerifyLocation  session_cookie=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDIzODg0OTQsImlhdCI6MTU0MjM4ODQzNCwiZGV2bmFtZSI6IkFjbWVBcHBDbyIsImFwcG5hbWUiOiJzb21lYXBwbGljYXRpb25BdXRoIiwiYXBwdmVycyI6IjEuMCJ9.rc7V12dgiYDforzBQrPh

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "VerifyCookie failed: Invalid cookie, no key"

VerifyLocation - request with expired cookie should return 'token is expired by'
   [Documentation]
   ...  Send VerifyLocation with expired session cookie
   ...  verify 'token is expired by' error is received

   ${exp_cookie}=  Generate Session Cookie
   Log to console  ${exp_cookie}

   #  EDGECLOUD-339 - FindCloudlet - wrong error is returned when sending expired session cookie	
   ${error_msg}=  Run Keyword And Expect Error  *  Verify Location  session_cookie=${exp_cookie}   latitude=1  longitude=1

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "token is expired by

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    Create App              

