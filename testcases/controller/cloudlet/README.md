### Cloudlet Testcases
* CreateCloudlet with all parameters - createCloudlet.robot
* CreateCloudlet without the optional parameters - createCloudlet.robot
* CreateCloudlet with required parameters and accessuri - createCloudlet.robot
* CreateCloudlet with required parameters and ipsupport - createCloudlet.robot
* CreateCloudlet with required parameters and staticips - createCloudlet.robot
* CreateCloudlet without an operator - createCloudlet_fail.robot
* CreateCloudlet with an invalid operator - createCloudlet_fail.robot
* CreateCloudlet without a name - createCloudlet_fail.robot
* CreateCloudlet with a location of 0 0 - createCloudlet_fail.robot
* CreateCloudlet with a location of 100 200 - createCloudlet_fail.robot
* CreateCloudlet with a location of -100 -200 - createCloudlet_fail.robot
* CreateCloudlet with numdynamic set to 0 - createCloudlet_fail.robot
* CreateCloudlet with an invalid ipsupport enumeration -1 - createCloudlet_fail.robot
* CreateCloudlet with an invalid ipsupport IPSupportStatic - createCloudlet_fail.robot
* CreateCloudlet with an invalid ipsupport enumeration 3 - createCloudlet_fail.robot
* ShowCloudlets all - showCloudlet.robot
* ShowCloudlets selected - showCloudlet.robot
* ShowCloudlets invalid - showCloudlet.robot
* UpdateCloudlet accessuri - updateCloutlet.robot
* UpdateCloudlet staticips - updateCloutlet.robot
* UpdateCloudlet number_of_dynamic_ips - updateCloutlet.robot
* UpdateCloudlet location - updateCloutlet.robot
* UpdateCloudlet location lat - updateCloutlet.robot
* UpdateCloudlet location long - updateCloutlet.robot
* UpdateCloudlet optional accessuri - updateCloutlet.robot
* UpdateCloudlet optional staticips - updateCloutlet.robot
* UpdateCloudlet without an operator - updateCloutlet_fail.robot
* UpdateCloudlet with an invalid operator - updateCloutlet_fail.robot
* UpdateCloudlet without a cloudlet name - updateCloutlet_fail.robot
* UpdateCloudlet with an invalid cloudlet name - updateCloutlet_fail.robot
* UpdateCloudlet with a numdynamicips 0 - updateCloutlet_fail.robot
* UpdateCloudlet with a numdynamicips -1 - updateCloutlet_fail.robot
* UpdateCloudlet with a numdynamicips A - updateCloutlet_fail.robot
* UpdateCloudlet with a numdynamicips 2323232232323 - updateCloutlet_fail.robot
* UpdateCloudlet with a ipsupport of -1 - updateCloutlet_fail.robot
* UpdateCloudlet with a ipsupport of -8 - updateCloutlet_fail.robot
* UpdateCloudlet with a location of 0 0 - updateCloutlet_fail.robot
* UpdateCloudlet with a location of 100 200 - updateCloutlet_fail.robot
* UpdateCloudlet with a location of -100 -200 - updateCloutlet_fail.robot
* UpdateCloudlet with a location of A A - updateCloutlet_fail.robot
* UpdateCloudlet with accessuri of 6 - updateCloutlet_fail.robot
* UpdateCloudlet with staticips of 6 - updateCloutlet_fail.robot
* DeleteCloudlet without an operator - deleteCloudlet.robot
* DeleteCloudlet with an invalid operator - deleteCloudlet.robot
* DeleteCloudlet without a cloudlet name - deleteCloudlet.robot
* DeleteCloudlet with an invalid cloudlet name - deleteCloudlet.robot
* DeleteCloudlet with a valid operator and cloudlet name - deleteCloudlet.robot
