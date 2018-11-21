*** Settings ***
Documentation  RegisterClient - 'app not found' error should be recieved parameters that dont match any app instances


Library  MexDme  dme_address=${dme_api_address}
Library		MexController  controller_address=${controller_api_address}

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${controller_api_address}  127.0.0.1:55001
${app_name}  someapplication   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0

${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

*** Test Cases ***
RegisterClient - request should return 'app not found' with wrong app_name
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy  app_version=${app_version}  developer_name=${developer_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "app not found"

RegisterClient - request should return 'app not found' with wrong app_version
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=1.1  developer_name=${developer_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "app not found"

RegisterClient - request should return 'app not found' with wrong developer_name
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=dummy

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "app not found"

RegisterClient - request should return 'app not found' with wrong app_name,app_version, and developer_name
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy  app_version=dummy  developer_name=dummy

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "app not found"

RegisterClient - request should return 'app not found' with wrong app_name and then succeed again with app added
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy  app_version=${app_version}  developer_name=${developer_name}
   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "app not found"

   # create app and register again
   Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}
   Create Cluster		cluster_name=default  default_flavor_name=${flavor}
   Create App	app_name=dummy  developer_name=${developer_name}  app_version=${app_version}  image_type=ImageTypeDocker  access_ports=tcp:1  ip_access=IpAccessDedicated  cluster_name=default  default_flavor_name=${flavor}
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=dummy  app_version=${app_version}  developer_name=${developer_name}
   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "app not found"

   # add appinst and then register should pass
   Create App Instance		app_name=dummy  developer_name=${developer_name}  app_version=${app_version}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
   Register Client	app_name=dummy  app_version=${app_version}  developer_name=${developer_name}
   ${decoded_cookie}=  decoded session cookie
   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   Should Be Equal  ${decoded_cookie['key']['devname']}  ${developer_name}	
   Should Be Equal  ${decoded_cookie['key']['appname']}  dummy	
   Should Be Equal  ${decoded_cookie['key']['appvers']}  ${app_version}	

   [Teardown]  Cleanup provisioning

