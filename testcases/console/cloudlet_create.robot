*** Settings ***
Documentation   Create new cloudlet

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123

*** Test Cases ***
Web UI - user shall be able to create a new EU cloudlet
    [Documentation]
    ...  Create a new flavor
    ...  Verify flavor shows in list

    Open Cloudlets

    #Get Table Data

    Add New Cloudlet  region=EU  

    Cloudlet Should Exist

    Sleep  5s

    Delete Cloudlet  #region=EU  cloudlet_name=cloudlet1560119652-3246112  operator=operator1560119652-3246112  #latitude=10  longitude=10

    Cloudlet Should Not Exist

#Web UI - user shall be able to create a new US flavor
#    [Documentation]
#    ...  Click New button
#    ...  Fill in Region=US and all proper values
#    ...  Verify Flavor is created and list is updated
#
#    Open Flavors
#
#    Get Table Data
#
#    Add New Flavor  region=US  flavor_name=andyFlavor  ram=1024  vcpus=1  disk=1
#
#    Flavor Should Exist

    #Sleep  10s

*** Keywords ***
Setup
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
