*** Settings ***
Documentation   UpdateApp manifest 

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         RequestsLibrary

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${manifest_tcp}  http://35.199.188.102/apps/iperfapp.yml
${manifest_udp}  http://35.199.188.102/apps/iperfudpapp.yml

${access_ports_tcp}  tcp:2011
${access_ports_udp}  udp:2011
	
*** Test Cases ***
UpdateApp - user shall be able to update the manifest
    [Documentation]
    ...  create an app with tcp access port and tcp manifest
    ...  verify app ports and manifest are correct
    ...  update the app changing port and manifest to udp 
    ...  verify app ports and manifest are updated
	
    ${app1}=  Create App  access_ports=${access_ports_tcp}  deployment_manifest=${manifest_tcp}

    Should Be Equal     ${app1.deployment_manifest}  ${tcp_yml.text}	
    Should Be Equal     ${app1.access_ports}         ${access_ports_tcp}	

    ${app2}=  Update App  access_ports=${access_ports_udp}  deployment_manifest=${manifest_udp}

    Should Be Equal     ${app2.deployment_manifest}  ${udp_yml.text}	
    Should Be Equal     ${app2.access_ports}         ${access_ports_udp}	
	
*** Keywords ***
Setup
    Create Developer            
    Create Flavor

    Create Session      manifest_server         http://35.199.188.102
    ${tcp_yml}          Get Request             manifest_server      apps/iperfapp.yml  
    ${udp_yml}          Get Request             manifest_server      apps/iperfudpapp.yml  

    Set Suite Variable  ${tcp_yml}
    Set Suite Variable  ${udp_yml}

