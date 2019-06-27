*** Settings ***
Documentation  use FQDN to access app on openstack

Library  MexApp

Test Timeout   1 min 

*** Variables ***
${udp_fqdn}       server-ping-theaded3-udp.bonncluster.automationbonncloudlet.tdg.mobiledgex.net
${tcp_fqdn}       server-ping-theaded3-tcp.bonncluster.automationbonncloudlet.tdg.mobiledgex.net 
${http_fqdn}       my

${udp_port}   2016
${tcp_port}   2015
${http_port}  8080

${http_page}  xx

*** Test Cases ***
User shall be able to access port on openstack
    [Documentation]
    ...  deploy app with 1 UDP port
    ...  verify the port as accessible via fqdn

    UDP Port Should Be Alive  ${udp_fqdn}  ${udp_port}
    TCP Port Should Be Alive  ${tcp_fqdn}  ${tcp_port}
    #HTTP Port Should Be Alive  ${http_fqdn}  ${http_port}  ${http_page}

