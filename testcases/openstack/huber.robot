*** Settings ***
Documentation  Test Openstack

#Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}

*** Variables ***
${qcow_centos_openstack_image}  server_ping_threaded_centos7

*** Test Cases ***
Get Servers
    [Documentation]
    ...  get servers

    ${servers}=  Get Openstack Server List
    #log to console  ${servers}
    log to console  ${servers[0]['Image']}
    #Should Be Equal As Integers  ${limits['maxTotalVolumeGigabytes']}  5000                  # disk size
    #Should Be Equal As Integers  ${limits['totalGigabytesUsed']}       100                 # disk used
    #Should Be Equal As Integers  ${limits['maxTotalRAMSize']}          1024                 # ram size
	


Get Image
    [Documentation]
    ...  get image

    ${image}=  Get Openstack Image List
    log to console  ${image}

Get Network
    [Documentation]
    ...  get network

    ${network}=  Get Openstack Network List
    log to console  ${network}

Get Subnet
    [Documentation]
    ...  get subnet

    ${subnet}=  Get Openstack Subnet List
    log to console  ${subnet}

Get Router
    [Documentation]
    ...  get router

    ${router}=  Get Openstack Router List
    log to console  ${router}

Get Flavour
    [Documentation]
    ...  get flavour

    ${flavour}=  Get Openstack Flavour List
    log to console  ${flavour}

Get Security
    [Documentation]
    ...  get security

    ${security}=  Get Openstack Security List
    log to console  ${security}


#server list, create, delete, set properties
#image list, save, create, delete
#network list, create, delete
#subnet list, create, delete
#router create, delete, add and delete ports
#flavor list, show, create
#security group rule list and create
#show limits

