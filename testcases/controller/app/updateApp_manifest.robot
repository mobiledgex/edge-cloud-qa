*** Settings ***
Documentation   UpdateApp manifest 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         RequestsLibrary

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${manifest_tcp}  http://35.199.188.102/apps/iperfapp.yml
${manifest_udp}  http://35.199.188.102/apps/iperfudpapp.yml

${manifest}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${manifest_different_ports}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_different_ports.yml

${access_ports_tcp}  tcp:2011
${access_ports_udp}  udp:2011
	
*** Test Cases ***
# ECQ-1142
UpdateApp - user shall be able to update the manifest
    [Documentation]
    ...  - create an app with tcp access port and tcp manifest
    ...  - verify app ports and manifest are correct
    ...  - update the app changing port and manifest to udp 
    ...  - verify app ports and manifest are updated
	
    ${app1}=  Create App  access_ports=${access_ports_tcp}  deployment_manifest=${manifest_tcp}

    Should Be Equal     ${app1.deployment_manifest}  ${tcp_yml.text}	
    Should Be Equal     ${app1.access_ports}         ${access_ports_tcp}	

    ${app2}=  Update App  access_ports=${access_ports_udp}  deployment_manifest=${manifest_udp}

    Should Be Equal     ${app2.deployment_manifest}  ${udp_yml.text}	
    Should Be Equal     ${app2.access_ports}         ${access_ports_udp}	

# ECQ-2557
UpdateApp - user shall not be able to update to invalid manifest
    [Documentation]
    ...  - create an app with tcp access port and tcp manifest
    ...  - verify app ports and manifest are correct
    ...  - update the app with invalid manifest
    ...  - verify proper error is received

    ${app1}=  Create App  access_ports=${access_ports_tcp}  deployment_manifest=${manifest_tcp}

    Should Be Equal     ${app1.deployment_manifest}  ${tcp_yml.text}
    Should Be Equal     ${app1.access_ports}         ${access_ports_tcp}

    ${error}=  Run Keyword and Expect Error  *  Update App  access_ports=${access_ports_udp}  deployment_manifest=xx

    Should Contain  ${error}  Invalid deployment manifest, parse kubernetes deployment yaml failed,

# ECQ-2558
UpdateApp - user shall be able to update k8s/lb ports with auto-generated manifest
    [Documentation]
    ...  - create a k8s/lb app with tcp access port and tcp manifest
    ...  - verify app ports and manifest are correct
    ...  - update the app changing port and manifest to various port configurations
    ...  - verify app ports and manifest are updated

    ${app1}=  Create App  access_ports=tcp:1  deployment=kubernetes   access_type=loadbalancer

    Should Be Equal  ${app1.access_ports}         tcp:1

    Should Contain   ${app1.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp1${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 1${\n}${SPACE*4}targetPort: 1${\n}
    Should Contain   ${app1.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 1${\n}${SPACE*10}protocol: TCP


    ${app2}=  Update App  access_ports=tcp:2
    Should Contain      ${app2.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp2${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}
    Should Contain      ${app2.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: TCP
    Should Be Equal     ${app2.access_ports}         tcp:2

    ${app3}=  Update App  access_ports=udp:2
    Should Contain      ${app3.deployment_manifest}  ports:${\n}${SPACE*2}- name: udp2${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}
    Should Contain      ${app3.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: UDP
    Should Be Equal     ${app3.access_ports}         udp:2

    ${app4}=  Update App  access_ports=tcp:2-4
    Should Contain      ${app4.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp2${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}${SPACE*2}- name: tcp3${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 3${\n}${SPACE*4}targetPort: 3${\n}${SPACE*2}- name: tcp4${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 4${\n}${SPACE*4}targetPort: 4${\n}
    Should Contain      ${app4.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 3${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 4${\n}${SPACE*10}protocol: TCP
    Should Be Equal     ${app4.access_ports}         tcp:2-4

    ${app5}=  Update App  access_ports=tcp:2-4,udp:2-4
    Should Contain      ${app5.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp2${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}${SPACE*2}- name: tcp3${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 3${\n}${SPACE*4}targetPort: 3${\n}${SPACE*2}- name: tcp4${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 4${\n}${SPACE*4}targetPort: 4${\n}
    Should Contain      ${app5.deployment_manifest}  - name: udp2${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}${SPACE*2}- name: udp3${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 3${\n}${SPACE*4}targetPort: 3${\n}${SPACE*2}- name: udp4${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 4${\n}${SPACE*4}targetPort: 4${\n}
    Should Contain      ${app5.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 3${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 4${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: UDP${\n}${SPACE*8}- containerPort: 3${\n}${SPACE*10}protocol: UDP${\n}${SPACE*8}- containerPort: 4${\n}${SPACE*10}protocol: UDP
    Should Be Equal     ${app5.access_ports}         tcp:2-4,udp:2-4

UpdateApp - user shall be able to update k8s/direct ports with user manifest
    [Documentation]
    ...  - create a k8s/direct app with tcp access port and tcp manifest
    ...  - verify app ports and manifest are correct
    ...  - update the app changing port and manifest to various port configurations
    ...  - verify app ports and manifest are updated

    ${app1}=  Create App  access_ports=tcp:2016  deployment=kubernetes   access_type=loadbalancer  deployment_manifest=${manifest}

    Should Be Equal  ${app1.access_ports}         tcp:2016

#    Should Contain   ${app1.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp1${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 2016${\n}${SPACE*4}targetPort: 1${\n}
#    Should Contain   ${app1.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 1${\n}${SPACE*10}protocol: TCP


    ${app2}=  Update App  access_ports=tcp:8085
    Should Be Equal     ${app2.access_ports}         tcp:8085

    ${app3}=  Update App  access_ports=udp:2015
    Should Be Equal     ${app3.access_ports}         udp:2015

    ${app4}=  Update App  access_ports=tcp:2-4
    Should Contain      ${app4.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp2${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}${SPACE*2}- name: tcp3${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 3${\n}${SPACE*4}targetPort: 3${\n}${SPACE*2}- name: tcp4${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 4${\n}${SPACE*4}targetPort: 4${\n}
    Should Contain      ${app4.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 3${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 4${\n}${SPACE*10}protocol: TCP
    Should Be Equal     ${app4.access_ports}         tcp:2-4

    ${app5}=  Update App  access_ports=tcp:2-4,udp:2-4
    Should Contain      ${app5.deployment_manifest}  ports:${\n}${SPACE*2}- name: tcp2${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}${SPACE*2}- name: tcp3${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 3${\n}${SPACE*4}targetPort: 3${\n}${SPACE*2}- name: tcp4${\n}${SPACE*4}protocol: TCP${\n}${SPACE*4}port: 4${\n}${SPACE*4}targetPort: 4${\n}
    Should Contain      ${app5.deployment_manifest}  - name: udp2${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 2${\n}${SPACE*4}targetPort: 2${\n}${SPACE*2}- name: udp3${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 3${\n}${SPACE*4}targetPort: 3${\n}${SPACE*2}- name: udp4${\n}${SPACE*4}protocol: UDP${\n}${SPACE*4}port: 4${\n}${SPACE*4}targetPort: 4${\n}
    Should Contain      ${app5.deployment_manifest}  ports:${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 3${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 4${\n}${SPACE*10}protocol: TCP${\n}${SPACE*8}- containerPort: 2${\n}${SPACE*10}protocol: UDP${\n}${SPACE*8}- containerPort: 3${\n}${SPACE*10}protocol: UDP${\n}${SPACE*8}- containerPort: 4${\n}${SPACE*10}protocol: UDP
    Should Be Equal     ${app5.access_ports}         tcp:2-4,udp:2-4

# ECQ-2810
UpdateApp - user shall not be able to update ports only with user manifest
    [Documentation]
    ...  - create an app with tcp access port and tcp manifest
    ...  - verify app ports and manifest are correct
    ...  - update the app with port only
    ...  - verify proper error is received

    ${app1}=  Create App  access_ports=${access_ports_tcp}  deployment_manifest=${manifest_tcp}

    Should Be Equal     ${app1.deployment_manifest}  ${tcp_yml.text}
    Should Be Equal     ${app1.access_ports}         ${access_ports_tcp}

    ${error}=  Run Keyword and Expect Error  *  Update App  access_ports=${access_ports_udp}

    Should Contain  ${error}  Kubernetes manifest which was previously specified must be provided again when changing access ports 

# ECQ-2993
UpdateApp - user shall be able to update manifest/ports with externalports != internalports
    [Documentation]
    ...  - create an app with manifest where port and targetport are same value
    ...  - verify app ports and manifest are correct
    ...  - update the app with new accessports/manifest which has port and targetport with different values
    ...  - verify app is updated

    ${app1}=  Create App  access_ports=tcp:2016,udp:2015,tcp:8085  deployment_manifest=${manifest}
    Should Be Equal  ${app1.access_ports}  tcp:2016,udp:2015,tcp:8085
    Should Contain   ${app1.deployment_manifest}  port: 2015\n    targetPort: 2015
    Should Contain   ${app1.deployment_manifest}  port: 2016\n    targetPort: 2016
    Should Contain   ${app1.deployment_manifest}  port: 8085\n    targetPort: 8085

    ${app2}=  Update App  access_ports=tcp:2116,udp:2115,tcp:8185  deployment_manifest=${manifest_different_ports}
    Should Be Equal  ${app2.access_ports}  tcp:2116,udp:2115,tcp:8185
    Should Contain   ${app2.deployment_manifest}  port: 2115\n    targetPort: 2015
    Should Contain   ${app2.deployment_manifest}  port: 2116\n    targetPort: 2016
    Should Contain   ${app2.deployment_manifest}  port: 8185\n    targetPort: 8085

*** Keywords ***
Setup
    #Create Developer            
    Create Flavor

    Create Session      manifest_server         http://35.199.188.102
    ${tcp_yml}          Get Request             manifest_server      apps/iperfapp.yml  
    ${udp_yml}          Get Request             manifest_server      apps/iperfudpapp.yml  

    Set Suite Variable  ${tcp_yml}
    Set Suite Variable  ${udp_yml}

