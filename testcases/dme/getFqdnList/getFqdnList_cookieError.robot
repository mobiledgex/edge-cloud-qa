*** Settings ***
Documentation  GetFqdnList - various cookie erors


Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}

*** Variables ***
${carrier_name}  tmus
${expired_cookie}  eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDIzMTQ2MTEsImlhdCI6MTU0MjIyODIxMSwia2V5Ijp7InBlZXJpcCI6IjEyNy4wLjAuMSIsImRldm5hbWUiOiJBY21lQXBwQ28iLCJhcHBuYW1lIjoic29tZWFwcGxpY2F0aW9uMiIsImFwcHZlcnMiOiIxLjAifX0.GK6G0vCzlQosft7xKyC-wBjWomKBZ8JN6JfwuP6dozP9vqYSF53VjcwP0DEnyqR2-fwNJNdK1_mCzBKT3j_hJ0Rcf4U-GnNLFURNzjkBd-3XdT8C2L_XSEctMFf6BYg4GlajcteaKX-Lb__3TfEaG4gCfVcLoi1ZUqLOkY2Q2Qs0YCPM5YUU96PtY8DHNBjXu7nld3P-DFVxQYJHN9ITVnUxTkhf7dBcbnkpFClzQGkcXwuzjj_T7qg5WTHS9kEkbGFJDMENEFD_gIaLWbhzy2GnXaOWFrzVSxONgWSnazvJxjmrshpdw6_r6D68El7RhK_S5f0M3Hhi_yoBjjEhko6FGuIp2Z8VTrRvCTL2kWgS37hdeawbBWNorQ1Mzh_zk05ZDO-i-CE-zJVX5Qk0A1dlrAI_onVNScK3ijwIT-vrlSwalVmgyrijlQiXuE6wzWMiLTH9oGbeD4c-lXlSGNLTRNWLzsCv2r56QmzKuxWysQ73yb8GxaJuPAHp8udCKHUUhpHZUcfnH-1z7_vd_X1cOEYTq4lYF4n47e71wa5bXitD7nacXOzPh5Jc1gxCP355g12LX7rz_BvZ7VYQQjJVnIlO9mNj66K9ifb9zFqBvD7u0mAqoy_zyIp7rETYjYdL8klzeD93h205JAWboKUrWgUToCNfuDGJ4MCxad8
	
*** Test Cases ***
GetFqdnList - request without cookie should return 'missing cookie'
    [Documentation]
    ...  Send GetFqdnList without a session cookie
    ...  verify 'missing cookie' error is received
	
   # no register thus no cookie
   #Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}  auth_token=1234
   ${error_msg}=  Run Keyword And Expect Error  *  Get FQDN List 

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "VerifyCookie failed: missing cookie"

GetFqdnList - request with invalid cookie of x should return 'token contains an invalid number of segments'
   [Documentation]
   ...  Send getFqdnList with session cookie of 'x'
   ...  verify 'token contains an invalid number of segments' error is received

   ${error_msg}=  Run Keyword And Expect Error  *  Get Fqdn List  session_cookie=x

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "token contains an invalid number of segments"

GetFqdnList - request with invalid cookie of x.x.x should return 'illegal base64 data at input byte 1' with invalid cookie
   [Documentation]
   ...  Send GetFqdnList with session cookie of 'x.x.x'
   ...  verify 'illegal base64 data at input byte 1' error is received

   ${error_msg}=  Run Keyword And Expect Error  *  Get Fqdn List  session_cookie=x.x.x

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "illegal base64 data at input byte 1"

GetFqdnList - request with truncated cookie should return 'VerifyCookie failed: Invalid cookie, no key'
   [Documentation]
   ...  Send GetFqdnList with parital session cookie
   ...  verify 'VerifyCookie failed: Invalid cookie, no key' error is received
	
   #EDGECLOUD-338 - DME crashes when sending FindCloudlet with invalid session cookie - fixed
   ${error_msg}=  Run Keyword And Expect Error  *  Get Fqdn List  session_cookie=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDIzODg0OTQsImlhdCI6MTU0MjM4ODQzNCwiZGV2bmFtZSI6IkFjbWVBcHBDbyIsImFwcG5hbWUiOiJzb21lYXBwbGljYXRpb25BdXRoIiwiYXBwdmVycyI6IjEuMCJ9.rc7V12dgiYDforzBQrPh

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "VerifyCookie failed: Invalid cookie, no key"

GetFqdnList - request with expired cookie should return 'token is expired by'
   [Documentation]
   ...  Send FindCloudlet with expired session cookie
   ...  verify 'token is expired by' error is received

   #  EDGECLOUD-339 - FindCloudlet - wrong error is returned when sending expired session cookie	
   ${error_msg}=  Run Keyword And Expect Error  *  Get Fqdn List  session_cookie=${expired_cookie}

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "token is expired by
