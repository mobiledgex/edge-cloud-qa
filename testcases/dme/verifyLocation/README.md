### VerifyLocation Testcases
* VerifyLocation request shall return LOC_VERIFIED of 100km - verifyLocation_100km.robot
* VerifyLocation request shall return LOC_VERIFIED of 10km - verifyLocation_10km.robot
* VerifyLocation request shall return LOC_VERIFIED of 2km - verifyLocation_2km.robot
* VerifyLocation request shall return LOC_MISMATCH_OTHER_COUNTRY - verifyLocation_greater100km_other_country.robot
* VerifyLocation request shall return LOC_ROAMING_COUNTRY_MISMATCH - verifyLocation_greater100km_roaming_other_country.robot
* VerifyLocation request shall return LOC_ROAMING_COUNTRY_MATCH - verifyLocation_greater100km_roaming_same_country.robot
* VerifyLocation request shall return LOC_MISMATCH_SAME_COUNTRY - verifyLocation_greater100km_same_country.robot
* VerifyLocation request with bad token shall return LOC_ERROR_UNAUTHORIZED - verifyLocation_badToken.robot
* VerifyLocation request with various cookie errors - verifyLocation_cookieError.robot
* VerifyLocation request with carrier not found shall return 'carrier not found' - verifyLocation_carrierNotFound.robot
* VerifyLocation with missing parameters - verifyLocation_missingParms.robot
* VerifyLocation with bad token - verifyLocation_badToken.robot
