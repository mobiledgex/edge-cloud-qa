*** Settings ***
Documentation   Latency Edge Event Tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections

#Test Setup	Setup
Test Teardown	Teardown

Test Timeout    60s

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-3241
DMEPersistentConnection - Latency edge event shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with samples
    ...  - verify response has correct stats

    [Tags]  DMEPersistentConnection

    ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}	
    ${cloudlet}=  Find Cloudlet	 carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}

    ${average}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    ${stdev}=  Evaluate  round(statistics.stdev(@{samples}))  statistics
    ${variance}=  Evaluate  round(statistics.variance(@{samples}))  statistics
    ${num_samples}=  Get Length  ${samples}
    ${min}=  Evaluate  min(@{samples})
    ${max}=  Evaluate  max(@{samples})

    Create DME Persistent Connection  carrier_name=${operator_name_fake}x  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${latency}=  Send Latency Edge Event  carrier_name=${operator_name_fake}x  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}

    ${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    ${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    ${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    Should Be Equal  ${latency_avg}  ${average}
    Should Be Equal  ${latency.statistics.min}  ${min}
    Should Be Equal  ${latency.statistics.max}  ${max}
    Should Be Equal  ${latency_std_dev}  ${stdev}
    Should Be Equal  ${latency_variance}  ${variance}
    Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    Should Be True   ${latency.statistics.timestamp.seconds} > 0
    Should Be True   ${latency.statistics.timestamp.nanos} > 0

# ECQ-3242
DMEPersistentConnection - Latency edge event with no samples shall return no statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event without samples
    ...  - verify response has correct stats of all 0

    [Tags]  DMEPersistentConnection

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${latency}=  Send Latency Edge Event  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96 

    Should Be Equal As Numbers  ${latency.statistics.avg}                0
    Should Be Equal As Numbers  ${latency.statistics.min}                0
    Should Be Equal As Numbers  ${latency.statistics.max}                0
    Should Be Equal As Numbers  ${latency.statistics.std_dev}            0
    Should Be Equal As Numbers  ${latency.statistics.variance}           0
    Should Be Equal As Numbers  ${latency.statistics.num_samples}        0  
    Should Be Equal As Numbers  ${latency.statistics.timestamp.seconds}  0
    Should Be Equal As Numbers  ${latency.statistics.timestamp.nanos}    0

# ECQ-3243
DMEPersistentConnection - Latency edge event with 0 in samples shall return no statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with value of 0 in samples
    ...  - verify response has correct stats of all 0

    [Tags]  DMEPersistentConnection

    # EDGECLOUD-4493 EVENT_LATENCY_SAMPLES request with empty samples doesnt return all statistics fields
    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    @{samples}=  Create List  ${0}
    ${latency}=  Send Latency Edge Event  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}

    Should Be Equal As Numbers  ${latency.statistics.avg}                0
    Should Be Equal As Numbers  ${latency.statistics.min}                0
    Should Be Equal As Numbers  ${latency.statistics.max}                0
    Should Be Equal As Numbers  ${latency.statistics.std_dev}            0
    Should Be Equal As Numbers  ${latency.statistics.variance}           0
    Should Be Equal As Numbers  ${latency.statistics.num_samples}        0
    Should Be Equal As Numbers  ${latency.statistics.timestamp.seconds}  0
    Should Be Equal As Numbers  ${latency.statistics.timestamp.nanos}    0

# ECQ-3244
DMEPersistentConnection - Latency edge event with same numbers in samples shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with samples which have the same numbers
    ...  - verify response has correct stats 

    [Tags]  DMEPersistentConnection

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    @{samples}=  Create List  ${1}  ${1}  ${1}  ${1}  ${1}
    ${latency}=  Send Latency Edge Event  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}

    Should Be Equal As Numbers  ${latency.statistics.avg}                1
    Should Be Equal As Numbers  ${latency.statistics.min}                1
    Should Be Equal As Numbers  ${latency.statistics.max}                1
    Should Be Equal As Numbers  ${latency.statistics.std_dev}            0
    Should Be Equal As Numbers  ${latency.statistics.variance}           0
    Should Be Equal As Numbers  ${latency.statistics.num_samples}        5
    Should Be True  ${latency.statistics.timestamp.seconds} > 0
    Should Be True  ${latency.statistics.timestamp.nanos} > 0

# ECQ-3245
DMEPersistentConnection - Latency edge event with negative in samples shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with samples which have the negative numbers
    ...  - verify negative numbers are ignored and response has correct stats

    [Tags]  DMEPersistentConnection

    EDGECLOUD-4520 DME should handle receipt of negative Latency Edge Event values

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    @{samples}=  Create List  ${-1}  ${-2}
    ${average}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    ${stdev}=  Evaluate  round(statistics.stdev(@{samples}))  statistics
    ${variance}=  Evaluate  round(statistics.variance(@{samples}))  statistics
    ${num_samples}=  Get Length  ${samples}
    ${min}=  Evaluate  min(@{samples})
    ${max}=  Evaluate  max(@{samples})

    ${latency}=  Send Latency Edge Event  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}

    ${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    ${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    ${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    Should Be Equal  ${latency_avg}  ${average}
    Should Be Equal  ${latency.statistics.min}  ${min}
    Should Be Equal  ${latency.statistics.max}  ${max}
    Should Be Equal  ${latency_std_dev}  ${stdev}
    Should Be Equal  ${latency_variance}  ${variance}
    Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    Should Be True   ${latency.statistics.timestamp.seconds} > 0
    Should Be True   ${latency.statistics.timestamp.nanos} > 0

# ECQ-3246
DMEPersistentConnection - Latency edge event with large samples shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with a large number of samples
    ...  - verify response has correct stats

    [Tags]  DMEPersistentConnection

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    @{samples}=  Evaluate  list(range(1,10000))
    ${average}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    ${stdev}=  Evaluate  round(statistics.stdev(@{samples}))  statistics
    ${variance}=  Evaluate  round(statistics.variance(@{samples}))  statistics
    ${num_samples}=  Get Length  ${samples}
    ${min}=  Evaluate  min(@{samples})
    ${max}=  Evaluate  max(@{samples})

    ${latency}=  Send Latency Edge Event  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}

    ${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    ${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    ${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    Should Be Equal  ${latency_avg}  ${average}
    Should Be Equal  ${latency.statistics.min}  ${min}
    Should Be Equal  ${latency.statistics.max}  ${max}
    Should Be Equal  ${latency_std_dev}  ${stdev}
    Should Be Equal  ${latency_variance}  ${variance}
    Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    Should Be True   ${latency.statistics.timestamp.seconds} > 0
    Should Be True   ${latency.statistics.timestamp.nanos} > 0

# ECQ-3247
DMEPersistentConnection - Latency edge event with device info shall return statistics
    [Documentation]
    ...  - make DME persistent connection
    ...  - send Latency Edge Event with samples and device info
    ...  - verify response has correct stats

    [Tags]  DMEPersistentConnection

    Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${70.45}
    ${average}=  Evaluate  round(statistics.mean(@{samples}))  statistics
    ${stdev}=  Evaluate  round(statistics.stdev(@{samples}))  statistics
    ${variance}=  Evaluate  round(statistics.variance(@{samples}))  statistics
    ${num_samples}=  Get Length  ${samples}
    ${min}=  Evaluate  min(@{samples})
    ${max}=  Evaluate  max(@{samples})

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${latency}=  Send Latency Edge Event  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96  samples=${samples}  device_info_data_network_type=5G  device_info_os=Android  device_info_model=Google Pixel  device_info_signal_strength=75

    ${latency_avg}=  Evaluate  round(${latency.statistics.avg})
    ${latency_std_dev}=  Evaluate  round(${latency.statistics.std_dev})
    ${latency_variance}=  Evaluate  round(${latency.statistics.variance})

    Should Be Equal  ${latency_avg}  ${average}
    Should Be Equal  ${latency.statistics.min}  ${min}
    Should Be Equal  ${latency.statistics.max}  ${max}
    Should Be Equal  ${latency_std_dev}  ${stdev}
    Should Be Equal  ${latency_variance}  ${variance}
    Should Be Equal  ${latency.statistics.num_samples}  ${num_samples}
    Should Be True   ${latency.statistics.timestamp.seconds} > 0
    Should Be True   ${latency.statistics.timestamp.nanos} > 0

# ECQ-3248
DMEPersistentConnection - client for docker app shall be able to receive Latency request
    [Documentation]
    ...  - create a docker appinst
    ...  - make DME persistent connection
    ...  - request App Inst Latency 
    ...  - verify client receives the request 
    [Tags]  DMEPersistentConnection
    Create Flavor  region=${region}
    Create App  region=${region}  access_ports=tcp:1  deployment=docker
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=docker
    ${tmus_appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Register Client  #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${app_name}=  Get Default App Name
    ${developer_org_name}=  Get Default Developer Name
    ${cluster_name}=  Get Default Cluster Name
    Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Receive Latency Edge Request

# ECQ-3323
DMEPersistentConnection - client for docker autocluster app shall be able to receive Latency request
    [Documentation]
    ...  - create a docker autocluster appinst
    ...  - make DME persistent connection
    ...  - request App Inst Latency 
    ...  - verify client receives the request 

    [Tags]  DMEPersistentConnection

    Create Flavor  region=${region}
    Create App  region=${region}  access_ports=tcp:1  deployment=docker
    ${tmus_appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autoclusterxx  cluster_instance_developer_org_name=MobiledgeX

    Register Client  #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${app_name}=  Get Default App Name
    ${developer_org_name}=  Get Default Developer Name
    ${cluster_name}=  Get Default Cluster Name
    Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=autoclusterxx  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Receive Latency Edge Request

# ECQ-3249
DMEPersistentConnection - client for k8s app shall be able to receive Latency request
    [Documentation]
    ...  - create a k8s appinst
    ...  - make DME persistent connection
    ...  - request App Inst Latency
    ...  - verify client receives the request

    [Tags]  DMEPersistentConnection

    Create Flavor  region=${region}
    Create App  region=${region}  access_ports=tcp:1  deployment=kubernetes
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=kubernetes
    ${tmus_appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Register Client  #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${app_name}=  Get Default App Name
    ${developer_org_name}=  Get Default Developer Name
    ${cluster_name}=  Get Default Cluster Name
    Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Receive Latency Edge Request

# ECQ-3250
DMEPersistentConnection - client for helm app shall be able to receive Latency request
    [Documentation]
    ...  - create a helm appinst
    ...  - make DME persistent connection
    ...  - request App Inst Latency
    ...  - verify client receives the request

    [Tags]  DMEPersistentConnection

    Create Flavor  region=${region}
    Create App  region=${region}  access_ports=tcp:1  deployment=helm  image_type=ImageTypeHelm
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=kubernetes
    ${tmus_appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Register Client  #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    ${app_name}=  Get Default App Name
    ${developer_org_name}=  Get Default Developer Name
    ${cluster_name}=  Get Default Cluster Name
    Request App Instance Latency  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}

    Receive Latency Edge Request

# ECQ-3251
DMEPersistentConnection - client for vm app shall be able to receive Latency request
    [Documentation]
    ...  - create a vm appinst
    ...  - make DME persistent connection
    ...  - request App Inst Latency
    ...  - verify client receives the request

    [Tags]  DMEPersistentConnection

    # fixed EDGECLOUD-4523 RequestAppInstLatency - request doesnt work for VM apps since it has no cluster instance

    ${app_name}=  Get Default App Name
    ${developer_org_name}=  Get Default Developer Name
    ${cluster_name}=  Get Default Cluster Name
    ${token}=  Get Super Token

    Create Flavor  region=${region}
    Create App  region=${region}  access_ports=tcp:1  deployment=vm  image_type=ImageTypeQcow  image_path=${qcow_centos_image}
    ${tmus_appinst}=  Create App Instance  region=${region}  token=${token}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}   use_defaults=${False}

    Register Client  #app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
    ${cloudlet}=  Find Cloudlet       carrier_name=${operator_name_fake}  latitude=36  longitude=-96

    Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
    Should Be True  len('${cloudlet.edge_events_cookie}') > 100

    Create DME Persistent Connection  carrier_name=TDG  edge_events_cookie=${cloudlet.edge_events_cookie}  latitude=36  longitude=-96

    Request App Instance Latency  token=${token}  region=${region}  app_name=${app_name}  app_version=1.0  developer_org_name=${developer_org_name}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  use_defaults=${False}

    Receive Latency Edge Request

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch

    ${app_name}=  Get Default App Name

    ${azure_cloudlet_name}=  Catenate  SEPARATOR=  ${azure_cloudlet_name}  ${epoch}

    Create Flavor  region=${region}
#    Create Cloudlet		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  latitude=${azure_cloudlet_latitude}  longitude=${azure_cloudlet_longitude}
    #Create Cloudlet		cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  latitude=${tmus_cloudlet_latitude}  longitude=${tmus_cloudlet_longitude}
    #Create Cluster		
    Create App  region=${region}  developer_org_name=andydevorg  access_ports=tcp:1
    ${tmus_appinst}=  Create App Instance  region=${region}  cluster_instance_developer_org_name=MobiledgeX  cloudlet_name=${tmus_cloudlet_name}  operator_org_name=${tmus_operator_name}  cluster_instance_name=autocluster
#    Create App Instance		cloudlet_name=${azure_cloudlet_name}  operator_org_name=${azure_operator_name}  cluster_instance_name=autocluster

   
    Set Suite Variable  ${tmus_appinst} 
    Set Suite Variable  ${app_name}

Teardown
   Terminate DME Persistent Connection
   Cleanup Provisioning
