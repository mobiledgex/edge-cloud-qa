*** Settings ***
Library                MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Teardown   Cleanup provisioning

*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreatTest
${region}=  US

*** Test Cases ***
# ECQ-1473
CreateCloudlet - cloudlet should fail if address already in use
    [Documentation]
        ...            send CreateCloudlet with address that is already in use
        ...            verify correct error is received

    #Create Cloudlet  operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default  latitude=35  longitude=-96  accesscredentials=https://support.sup.com/supersupport  ipsupport=IpSupportDynamic  staticips=30.30.30.1

    ${epoch}=  Get Time  epoch
    ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}

    ${error_msg}=  Run Keyword And Expect Error  *  MexController.Create Cloudlet  operator_org_name=${oper}  cloudlet_name=${cldlet}  number_of_dynamic_ips=5  latitude=35  longitude=-96  ipsupport=IpSupportDynamic  notify_server_address=127.0.0.1:37001

   Should Contain  ${error_msg}  Failure: ServerMgr listen failed {\\"err\\": \\"listen tcp 127.0.0.1:37001: bind: address already in use\\"}

