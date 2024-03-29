*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  OperatingSystem
Library  MexKnife
Variables  cloudletmanifest_vars.py

Test Timeout    ${test_timeout_crm}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${cloudlet_name_openstack_hawkins}  automationHawkinsCloudlet
${operator_name_openstack_hawkins}  GDDT
${physical_name_openstack_hawkins}  hawkins
${physical_name_crm}  buckhorn

${region}=  US

${test_timeout_crm}  60 min

*** Test Cases ***
# ECQ-2901
GetCloudletManifest - User shall be able to get cloudlet manifest, revoke and get again
   [Documentation]
   ...  - do CreateCloudlet with restricted access
   ...  - do GetCloudletManifest and check return
   ...  - do GetCloudletManifest again and verify error
   ...  - Revoke the key
   ...  - do GetCloudletManifest again and check return

   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}restricted  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_crm}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  infra_api_access=RestrictedAccess  infra_config_flavor_name=x1.medium  infra_config_external_network_name=external-network-shared  env_vars=${env_vars}

   Should Be Equal As Numbers  ${cloudlet['data']['infra_api_access']}   1
   #Should Be Equal  ${cloudlet['data']['infra_api_access']}   RestrictedAccess
   Should Be Equal  ${cloudlet['data']['infra_config']['external_network_name']}  external-network-shared 
   Should Be Equal  ${cloudlet['data']['infra_config']['flavor_name']}  x1.medium 
   
   ${cloudlet_manifest}=  Get Cloudlet Manifest  region=${region}   operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}restricted

   Should Contain  ${cloudlet_manifest['manifest']}  ${manifest_1}
   Should Contain  ${cloudlet_manifest['manifest']}  ${manifest_2}
   Should Contain  ${cloudlet_manifest['manifest']}  ${manifest_3}
   Should Match Regexp  ${cloudlet_manifest['manifest']}  ${manifest_3_private_key}
   Should Match Regexp  ${cloudlet_manifest['manifest']}  ${manifest_3_crm_access_key}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cloudlet has access key registered, please revoke the current access key first so a new one can be generated for the manifest"}')  Get Cloudlet Manifest  region=${region}   operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}restricted

   Revoke Access Key  region=${region}   operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}restricted

   ${cloudlet_manifest2}=  Get Cloudlet Manifest  region=${region}   operator_org_name=${operator_name_crm}  cloudlet_name=${cloudlet_name_crm}restricted

   Should Contain  ${cloudlet_manifest2['manifest']}  ${manifest_1}
   Should Contain  ${cloudlet_manifest2['manifest']}  ${manifest_2}
   Should Contain  ${cloudlet_manifest2['manifest']}  ${manifest_3}
   Should Match Regexp  ${cloudlet_manifest2['manifest']}  ${manifest_3_private_key}
   Should Match Regexp  ${cloudlet_manifest2['manifest']}  ${manifest_3_crm_access_key}

*** Keywords ***
Setup
   IF  'Buckhorn' in '${cloudlet_name_crm}'
      ${env_vars}=  Set Variable  FLAVOR_MATCH_PATTERN=m4,MEX_EXT_NETWORK=external-network-02
   ELSE
      ${env_vars}=  Set Variable  ${None}
   END

   Set Suite Variable  ${env_vars}

