*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout   25 min 

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

${test_timeout_crm}  60 min

*** Test Cases ***
# ECQ-4393
CreateCloudlet - User shall not be able to create a cloudlet with invalid infraconfig
   [Documentation]
   ...  - do CreateCloudlet with invalid infra config parm
   ...  - verify error occurs
   ...  - do it again to verify cleanup happened the 1st time and doesnt give cloudlet already exists

   ${error1}=  Run Keyword and Expect Error  *  Create Cloudlet  region=${region}   operator_org_name=${operator_name_crm}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_accessvars}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  infra_config_external_network_name=x  infra_config_flavor_name=y  timeout=900
   Should Be Equal  ${error1}  ('code=200', 'error={"result":{"message":"Unable to fetch gateway IP for external network: x, can\\\'t get details for external network x, can\\\'t get details for network x, Error while executing command: No Network found for x\\\\n, exit status 1","code":400}}')
 
   # run again to make sure cleanup happened after 1st failure
   ${error2}=  Run Keyword and Expect Error  *  Create Cloudlet  region=${region}   operator_org_name=${operator_name_crm}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_accessvars}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  infra_config_external_network_name=x  infra_config_flavor_name=y  timeout=900
   Should Be Equal  ${error2}  ('code=200', 'error={"result":{"message":"Unable to fetch gateway IP for external network: x, can\\\'t get details for external network x, can\\\'t get details for network x, Error while executing command: No Network found for x\\\\n, exit status 1","code":400}}')

*** Keywords ***
Setup
   #Create Org
   IF  'Buckhorn' in '${cloudlet_name_crm}'
      ${env_vars}=  Set Variable  FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02
   ELSE
      ${env_vars}=  Set Variable  ${None}
   END

   Set Suite Variable  ${env_vars}
