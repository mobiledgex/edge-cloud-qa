*** Settings ***
Documentation          This example demonstrates executing a command on a remote machine
...                    and getting its output.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Library                SSHLibrary
Suite Setup            Open Connection And Log In
Suite Teardown         Close All Connections
Test Timeout           2 minutes

*** Variables ***
${HOST}                37.50.200.18           #139.178.67.233
${USERNAME}            ubuntu                       #centos
#${PASSWORD}            test

*** Test Cases ***
Execute Command And Verify Output
    [Documentation]    Execute Command can be used to run commands on the remote machine.
    ...                The keyword returns the standard output by default.
    ${output}=         Execute Command    git clone https://github.com/ashutoshbhatt1/k8sperf.git
#    Should Be Equal    ${output}          Hello SSHLibrary!

*** Keywords ***
Open Connection And Log In
   Open Connection                 ${HOST}
   login with public key           ${USERNAME}     /Users/ashutoshbhatt/Downloads/id_rsa_mex
#   login with public key           ${USERNAME}   /Users/ashutoshbhatt/Documents/OpenstackRC/CentOS.pem