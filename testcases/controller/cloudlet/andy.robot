*** Settings ***
Library         MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

#Test Teardown   Cleanup provisioning


*** Variables ***
${controller_api_address}  127.0.0.1:55001
${oper}  azure
${cldlet}  CreateTest

*** Test Cases ***
CreateCloudlet with all parameters
        [Documentation]   CreateCloudlet - Creates a cloudlet with all of the parameters
        ...  The test case creates a cloudlet with all valid parameters
        ...  Expect the cloudlet to be created sucessfully

        ${epoch}=  Get Time  epoch
        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        FOR  ${inde}  IN RANGE  0  100        
        \  Create Cloudle  operator_name=${ope}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default     latitude=35     longitude=-96     accesscredentials=https://support.sup.com/supersupport   ipsupport=IpSupportDynamic    staticips=30.30.30.1

