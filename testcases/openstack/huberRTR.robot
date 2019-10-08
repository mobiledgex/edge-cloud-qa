*** Settings ***
Documentation  Test Openstack

Library  OperatingSystem
# Import Python Library
Library  json


#Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***
${qcow_centos_openstack_image}  server_ping_threaded_centos7

*** Test Cases ***

Get limits
    [Documentation]
    ...  get limits
    ${data_as_string} =    Get File    limits.json
    ${data_as_json} =    json.loads    ${data_as_string}
#    log to console  ${data_as_json}
    ${limits}=  Get Openstack Limits  ${data_as_json} 
#    log to console  ${limits}
#Get Servers
    #[Documentation]
    #...  get servers

    #${servers}=  Get Openstack Server List
    #log to console  ${servers}
    #log to console  ${servers[0]['Image']}
    #Should Be Equal As Integers  ${limits['maxTotalVolumeGigabytes']}  5000                  # disk size
    #Should Be Equal As Integers  ${limits['totalGigabytesUsed']}       100                 # disk used
    #Should Be Equal As Integers  ${limits['maxTotalRAMSize']}          1024                 # ram size
	
#Create Router
    #[Documentation]
    #...  create router

    #${router}=  Create Openstack Router  h12
#    log to console  ${router}

#    Router Should Exist  routerOutcome=${router}  name=h12 



#server list, create, delete, set properties
#image list, save, create, delete
#network list, create, delete
#subnet list, create, delete
#router create, delete, add and delete ports
#flavor list, show, create
#security group rule list and create
#show limits
