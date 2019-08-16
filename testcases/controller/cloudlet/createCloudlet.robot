*** Settings ***
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

Test Teardown	Cleanup provisioning


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
		
	Create Cloudlet	 operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default     latitude=35     longitude=-96     accesscredentials=https://support.sup.com/supersupport   ipsupport=IpSupportDynamic    staticips=30.30.30.1   
	Cloudlet Should Exist   

CreateCloudlet without the optional parameters
	[Documentation]   CreateCloudlet - Creates a cloudlet without the optional parameters
	...  The test case creates a cloudlet without accessuri, ipsupport, and staticips.
	...  Expect the cloudlet to be created sucessfully. Ipsupport will be set to IpSupportDynamic by default

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum} 

	Create Cloudlet	  operator_name=${oper}   cloudlet_name=${cldlet}    number_of_dynamic_ips=default     latitude=35     longitude=-96  notify_server_address=${port}   use_defaults=False
	Cloudlet Should Exist   

CreateCloudlet with required parameters and accessuri
	[Documentation]   CreateCloudlet - Creates a cloudlet with required parameters and the optional accessuri parameter
	...  The test case creates a cloudlet with required parameters and the optional accessuri parameter
	...  Expect the cloudlet to be created sucessfully. Ipsupport will be set to IpSupportDynamic by default

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet	 operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default     latitude=35     longitude=-96     accesscredentials=https://support.sup.com/supersupport  notify_server_address=${port}  use_defaults=False
	Cloudlet Should Exist   

CreateCloudlet with required parameters and ipsupport
		[Documentation]   CreateCloudlet - Creates a cloudlet with required parameters and the ipsupport parameter
	...  The test case creates a cloudlet with required parameters and the ipsupport parameter
	...  Expect the cloudlet to be created sucessfully

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet	 operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default     latitude=35     longitude=-96       ipsupport=IpSupportDynamic  notify_server_address=${port}  use_defaults=False
	Cloudlet Should Exist   

CreateCloudlet with required parameters and staticips
		[Documentation]   CreateCloudlet - Creates a cloudlet with required parameters and the optional staticips parameter
	...  The test case creates a cloudlet with required parameters and the optional staticips parameter
	...  Expect the cloudlet to be created sucessfully. Ipsupport will be set to IpSupportDynamic by default

        ${epoch}=  Get Time  epoch
        ${epochstring}=  Convert To String  ${epoch}

        ${cldlet}=  Catenate  SEPARATOR=  ${cldlet}  ${epoch}
        ${portnum}=  Get Substring  ${epochstring}  -5
        ${port}=  Catenate  SEPARATOR=  127.0.0.1:  ${portnum}

	Create Cloudlet	 operator_name=${oper}   cloudlet_name=${cldlet}   number_of_dynamic_ips=default     latitude=35     longitude=-96      staticips=30.30.30.1  notify_server_address=${port}   use_defaults=False
	Cloudlet Should Exist   

