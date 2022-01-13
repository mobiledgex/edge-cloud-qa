*** Settings ***
Documentation     Federation Resource Manager

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Timeout  10m

*** Variables ***
${selfoperator}  GDDT
${region}  EU
${selfcountrycode}  DE
${mcc}  49
${mnc1}  101
${partneroperator}  packet
${partnercountrycode}  SG
${partner_fed_id}


*** Test Cases ***
# ECQ-3755
Shall be able to unshare and delete federatorzones
    [Documentation]
    ...  Login as MexAdmin
    ...  Unshare a federatorzone
    ...  Delete the federatorzone

    Unshare FederatorZone  zoneid=${selfzone}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${super_token}
    Delete FederatorZone  zoneid=${selfzone}  operatorid=${selfoperator}  countrycode=${selfcountrycode}  token=${super_token}
    Delete Cloudlet  region=${region}  operator_org_name=${selfoperator}

