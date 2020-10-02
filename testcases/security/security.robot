*** Settings ***
Documentation  Security tests 

Library  Process 

#Test Setup      Setup
#Test Teardown   Cleanup Provisioning

*** Variables ***

*** Test Cases ***
# ECQ-2568
Security - LDAP port should not be open
    [Documentation]
    ...  - run nmap command against ldap port for the console
    ...  - verify port is not open

    # firewall should be up to close ldap port 
    #  
    # nmap -n -sV -p9389 --script "ldap* and not brute" console-qa.mobiledgex.net -oA nmap_console-qa.mobiledgex.net_ldap_9389
    # Starting Nmap 7.70 ( https://nmap.org ) at 2020-09-17 18:05 CDT
    # Nmap scan report for console-qa.mobiledgex.net (34.94.108.90)
    # Host is up (0.044s latency).
    # 
    # PORT     STATE    SERVICE VERSION
    # 9389/tcp filtered adws
    # 
    # Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    # Nmap done: 1 IP address (1 host up) scanned in 0.98 seconds

    # check console-qa
    ${out}=  Run Process  nmap  -n  -sV  -p9389  --script  ldap* and not brute  console-qa.mobiledgex.net  -oA  nmap_console-qa.mobiledgex.net_ldap_9389   stdout=STDOUT  stderr=STDOUT
    Should Contain  ${out.stdout}  9389/tcp filtered
    Should Not Contain  ${out.stdout}  open
    Should Not Contain  ${out.stdout}  ldap


    # check console
    ${out1}=  Run Process  nmap  -n  -sV  -p9389  --script  ldap* and not brute  console.mobiledgex.net  -oA  nmap_console.mobiledgex.net_ldap_9389   stdout=STDOUT  stderr=STDOUT
    Should Contain  ${out1.stdout}  9389/tcp filtered
    Should Not Contain  ${out1.stdout}  open
    Should Not Contain  ${out1.stdout}  ldap

    # check console-stage
    ${out2}=  Run Process  nmap  -n  -sV  -p9389  --script  ldap* and not brute  console-stage.mobiledgex.net  -oA  nmap_console-stage.mobiledgex.net_ldap_9389   stdout=STDOUT  stderr=STDOUT
    Should Contain  ${out2.stdout}  9389/tcp filtered
    Should Not Contain  ${out2.stdout}  open
    Should Not Contain  ${out2.stdout}  ldap

