*** Settings ***
Documentation   Delete test flavors
Library		      MexConsole           url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           10 min

*** Test Cases ***
WebUI - user shall be able to Delete a Flavor
    [Documentation]
    ...  Load flavor page
    ...  Create flavor to delete
    ...  Delete created flavor and confirm successfully updated
    [Tags]  passing

    #@{table_data_pre}=  Get Table Data
    #${num_pre}=  Get Length  ${table_data_pre}
    ${num_pre}=   Find Number of Entries

    Add New Flavor  region=EU

    Flavor Should Exist  change_rows_per_page=True  number_of_pages=${num_pages}  
    Log To Console  Flavor exists

    MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off
    Sleep  2

    #@{table_data_post}=  Get Table Data
    #${num_post}=  Get Length  ${table_data_post}
    ${num_post}=   Find Number of Entries
    # The counting should be changed once the bug for deleting a flavor resorts the table_data_pre
    # since the rows get changed in order once you delete a flavor

    Should Be Equal  ${num_pre}  ${num_post}

WebUI - user shall be able to cancel a Delete Flavor
    [Documentation]
    ...  Load flavor page
    ...  Create flavor to try and delete
    ...  Click delete flavor and then click cancel
    ...  Confirm flavor list is unchanged
    [Tags]  passing

    Open Flavors
    Add New Flavor  region=US
    #@{table_data_pre}=  Get Table Data
    Flavor Should Exist  change_rows_per_page=True  number_of_pages=${num_pages} 

    MexConsole.Delete Flavor  decision=no  number_of_pages=${num_pages}  click_previous_page=off
    @{table_data_post}=  Get Table Data

    MexConsole.Delete Flavor  number_of_pages=${num_pages}  click_previous_page=off

    #Should Be Equal  ${table_data_pre}  ${table_data_post}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Flavors
    Sleep  2
    ${num_pages}=  Find Number Of Pages
    Set Suite Variable  ${num_pages}

Teardown
    #Cleanup Provisioning
    Close Browser
    Run Keyword and Ignore Error  MexMasterController.Delete Flavor

