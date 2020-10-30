*** Settings ***
Documentation  use FQDN to access app on openstack

Library  MexApp

Test Timeout   1 min 

*** Variables ***
# server-ping-theaded3-udp.bonncluster.automationbonncloudlet.tdg.mobiledgex.net
# automation-sdk-porttest-udp.automationfrankfurtcloudlet.tdg.mobiledgex.net
# 4015 is the default for starting stopped ports		
${udp_fqdn}       automation-sdk-porttest-udp.automationfrankfurtcloudlet.tdg.mobiledgex.net
${tcp_fqdn}       automation-sdk-porttest-tcp.automationfrankfurtcloudlet.tdg.mobiledgex.net
${http_fqdn}      automation-sdk-porttest-tcp.automationfrankfurtcloudlet.tdg.mobiledgex.net

${udp_port}   2015
${tls_port}   2015
${tcp_port}   2016
${http_port}  8085

${http_page}  /automation.html

*** Test Cases ***
User shall be able to access port on openstack
    [Documentation]
    ...  deploy app with 1 UDP port
    ...  verify the port as accessible via fqdn

    #Egress Port Should Be Accessible  vm=cpc1598321065115894dkerprivplcy.dfwvmw2.packet.mobiledgex.net  host=35.199.188.102  protocol=tcp  port=2015

    #Stop TCP Port  ${tcp_fqdn}  ${tcp_port}
    #Start TCP Port  ${tcp_fqdn}   ${tcp_port}
    #Stop TCP Port  ${tcp_fqdn}  ${tcp_port}
    UDP Port Should Be Alive  ${udp_fqdn}  ${udp_port}
    TCP Port Should Be Alive  ${tcp_fqdn}  ${tls_port}  tls=${True}	
    TCP Port Should Be Alive  ${tcp_fqdn}  ${tcp_port} 
    HTTP Port Should Be Alive  ${http_fqdn}  ${http_port}  ${http_page}

