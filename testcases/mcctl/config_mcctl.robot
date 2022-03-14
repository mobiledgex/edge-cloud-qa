*** Settings ***
Documentation  config mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

Test Timeout  2m

*** Variables ***
${notify}=   mexcontester@gmail.com
	

*** Test Cases ***
# ECQ-2863
ResetConfig - mcctl shall be able to reset/show config
	[Documentation]
	...  - send Reset/Show Config via mcctl 
	...  - verify config is reset/shows the default config in the load
	
	# resets to the default config in the load
	Success Reset/Show Config Via mcctl


# ECQ-2864
UpdateConfig - mcctl shall handle update/show config changes
	[Documentation]
	...  - send UpdateConfig via mcctl with various parameters
	...  - verify proper parameter is set correctly

	[Template]  Update Config/Show Config Via mcctl
	# update locknewaccounts to true
        locknewaccounts=${True}

        # update skipverifyemail
	skipverifyemail=${True}

	# update notifyemailaddress
	notifyemailaddress=${notify}

        # update password crack times
        passwordmincracktimesec=1  adminpasswordmincracktimesec=2

        # token valid duration
        userlogintokenvalidduration=5m  apikeylogintokenvalidduration=5m1s   websockettokenvalidduration=5m2s

# ECQ-2865
UpdateConfig - mcctl shall handle update failures
	[Documentation]
	...  - send UpdateConfig via mcctl with various error cases
	...  - verify proper error is received

	[Template]  Fail Update Config Via mcctl
	Error: parsing arg "locknewaccounts\=any" failed: unable to parse "any" as bool: invalid syntax, valid values are true, false  locknewaccounts=any
	 Error: parsing arg "skipverifyemail\=any" failed: unable to parse "any" as bool: invalid syntax, valid values are true, false  skipverifyemail=any
        # we now support 1 and 0
	#Error: unmarshal err on locknewaccounts (StructNamespace), 1, bool, yaml: unmarshal errors:  locknewaccounts=1
	#Error: unmarshal err on locknewaccounts (StructNamespace), 0, bool, yaml: unmarshal errors:  locknewaccounts=0
	#Error: unmarshal err on skipverifyemail (StructNamespace), 1, bool, yaml: unmarshal errors:  skipverifyemail=1
	#Error: unmarshal err on skipverifyemail (StructNamespace), 0, bool, yaml: unmarshal errors:  skipverifyemail=0
	Bad Request (400), Admin password min crack time must be greater than password min crack time  passwordmincracktimesec=63072001
	Bad Request (400), Admin password min crack time must be greater than password min crack time  adminpasswordmincracktimesec=1

        Error: parsing arg "userlogintokenvalidduration\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  userlogintokenvalidduration=x
        Error: parsing arg "apikeylogintokenvalidduration\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  apikeylogintokenvalidduration=x
        Error: parsing arg "websockettokenvalidduration\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc  websockettokenvalidduration=x

# ECQ-2866
VersionConfig - mcctl shall show the config version
	[Documentation]
	...  - send  VersionConfig via mcctl 
	...  - verify proper information is received

	Show Config Version Via mcctl


*** Keywords ***
Success Reset/Show Config Via mcctl
	Run mcctl   config reset 
	${show}=  Run mcctl  config show

	Should Be Equal  ${show['LockNewAccounts']}  ${False}
	Should Be Equal  ${show['SkipVerifyEmail']}  ${False}
	Should Be Equal  ${show['NotifyEmailAddress']}  support@mobiledgex.com
	Should Be Equal As Integers  ${show['AdminPasswordMinCrackTimeSec']}  63072000
	Should Be Equal As Integers  ${show['PasswordMinCrackTimeSec']}  2592000
        Should Be Equal  ${show['UserLoginTokenValidDuration']}	  24h0m0s
        Should Be Equal  ${show['ApiKeyLoginTokenValidDuration']}   4h0m0s
        Should Be Equal  ${show['WebsocketTokenValidDuration']}   2m0s


Update Config/Show Config Via mcctl
	[Arguments]  &{parms}

	${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

	Run mcctl  config reset 
	Run mcctl  config update ${parmss}
	${show}=  Run mcctl  config show

	Run Keyword If  'locknewaccounts' in ${parms}  Should Be Equal  ${show['LockNewAccounts']}  ${True}
	Run Keyword If  'skipverifyemail' in ${parms}  Should Be Equal  ${show['SkipVerifyEmail']}  ${True}
	Run Keyword If  'notifyemailaddress' in ${parms}  Should Be Equal  ${show['NotifyEmailAddress']}  ${notify}
	Run Keyword If  'adminpasswordmincracktimesec' in ${parms}  Should Be Equal As Integers  ${show['AdminPasswordMinCrackTimeSec']}  2
	Run Keyword If  'passwordmincracktimesec' in ${parms}  Should Be Equal As Integers  ${show['PasswordMinCrackTimeSec']}  1

        Run Keyword If  'userlogintokenvalidduration' in ${parms}  Should Be Equal  ${show['UserLoginTokenValidDuration']}  5m0s
        Run Keyword If  'apikeylogintokenvalidduration' in ${parms}     Should Be Equal  ${show['ApiKeyLoginTokenValidDuration']}  5m1s
        Run Keyword If  'websockettokenvalidduration' in ${parms}  Should Be Equal  ${show['WebsocketTokenValidDuration']}  5m2s


Fail Update Config Via mcctl
	[Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

	${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

	${std_update}=  Run Keyword and Expect Error  *  Run mcctl  config update ${parmss}
	Should Contain Any  ${std_update}  ${error_msg}  ${error_msg2}



Show Config Version Via mcctl
	${show}=  Run mcctl   config version
	Should Not Be Empty  ${show['buildmaster']}
	Should Not Be Empty  ${show['buildhead']}
	Should Not Be Empty  ${show['hostname']}



Cleanup Provisioning
	${parms}=  Create Dictionary  skipverifyemail=${True}   locknewaccounts=${True}   notifyemailaddress=${notify}

	${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
	
	# Sets the config to normal QA config
	Run mcctl   config reset 
	Run mcctl   config update ${parmss}
	${show}=  Run mcctl  config show


	Should Be Equal  ${show['LockNewAccounts']}  ${True}
	Should Be Equal  ${show['SkipVerifyEmail']}  ${True}
	Should Be Equal  ${show['NotifyEmailAddress']}  ${notify}
	Should Be Equal As Integers  ${show['AdminPasswordMinCrackTimeSec']}  63072000
	Should Be Equal As Integers  ${show['PasswordMinCrackTimeSec']}  2592000
