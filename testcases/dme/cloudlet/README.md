### FindCloudlet Testcases
* findCloudlet shall return azure with with azure cloudlet provisioned and closer by more than 100km - findCloudlet_azure_azureCloser.robot
* request shall return azure with dmuus and gcp/azure cloudlet provisioned and dmuus farther and > 100km than azure and gcp and azure closer than gcp - findCloudlet_azure_azureCloserThanTmusGcp_azureGreaterThan100km_gcpGreaterThan100km.robot
* request shall return azure with dmuus and gcp/azure cloudlet provisioned and dmuus farther but > 100km than azure and < 100km than gcp and azure closer than gcp - findCloudlet_azure_azureCloserThanTmusGcp_azureGreaterThan100km_gcpLessThan100km.robot
* request shall return azure with dmuus and gcp/azure cloudlet provisioned and requesting azure - findCloudlet_azure_requestAzure.robot
* findCloudlet with various cookie errors - findCloudlet_cookieError.robot
* request shall return gcp with dmuus and gcp/azure cloudlet provisioned and dmuus farther and > 100km from gcp and azure and gcp closer than azure - findCloudlet_gcp_GcpCloserThanTmusAzure_gcpGreaterThan100km_azureGreaterThan100km.robot
* request shall return gcp with dmuus farther and > 100km farther than gcp - findCloudlet_gcp_gcpCloser.robot
* request shall return gcp with dmuus and gcp/azure cloudlet provisioned and dmuus farther and > 100km than gcp and < 100km than azure and gcp closer than azure - findCloudlet_gcp_gcpCloserThanTmusAzure_gcpGreaterThan100km_azureLessThan100km.robot
* request shall return gcp with dmuus and gcp/azure cloudlet provisioned and requesting gcp - findCloudlet_gcp_requestGcp.robot
* findCloudlet with various missing parms - findCloudlet_missingParms.robot
* request shall return dmuus with azure cloudlet closer but no appinst provisioned - findCloudlet_dmuus_azureCloser_noAppinst.robot
* request shall return FIND_NOT_FOUND when requesting an operator that doesnt exist - findCloudlet_dmuus_cloudletNotFound.robot
* request shall return dmuus with gcp cloudlet closer but no appinst provisioned - findCloudlet_dmuus_gcpCloser_noAppinst.robot
* request shall return proper cloudlet when multiple cloudlets exist - findCloudlet_dmuus_multiple.robot
* request shall return dmuus with no gcp/azure provisioned ond same coord as tmocloud-1 - findCloudlet_dmuus_noGcpNoAzure.robot
* request shall return dmuus with azure cloudlet provisioned and dmuus and azure same coord - findCloudlet_dmuus_dmuusAzureSameCoord.robot
* FindCloudlet shall return dmuus with azure cloudlet provisioned and dmuus and azure same distance - findCloudlet_dmuus_dmuusAzureSameDistance.robot
* request shall return dmuus with azure cloudlet provisioned and dmuus closer and > 100km from request - findCloudlet_dmuus_dmuusCloserThanAzureGreaterThan100km.robot
* request shall return dmuus with azure cloudlet provisioned and dmuus closer and < 100km from request - findCloudlet_dmuus_dmuusCloserThanAzureLessThan100km.robot
* request shall return dmuus with gcp/azure cloudlet provisioned and dmuus closer and > 100km from request - findCloudlet_dmuus_dmuusCloserThanGcpAzureGreaterThan100km.robot
* request shall return dmuus with gcp/azure cloudlet provisioned and dmuus closer and < 100km from request - findCloudlet_dmuus_dmuusCloserThanGcpAzureLessThan100km.robot
* request shall return dmuus with gcp/azure cloudlet provisioned and dmuus closer and with large distances - findCloudlet_dmuus_dmuusCloserThanGcpAzure_largeDistance.robot
* request shall return dmuus with gcp cloudlet provisioned and dmuus closer and > 100km from request - findCloudlet_dmuus_dmuusCloserThanGcpGreaterThan100km.robot
* request shall return dmuus with gcp cloudlet provisioned and dmuus closer and < 100km from request - findCloudlet_dmuus_dmuusCloserThanGcpLessThan100km.robot
* request shall return dmuus with azure cloudlet provisioned and dmuus farther but < 100km than azure - findCloudlet_dmuus_dmuusFartherThanAzureLessThan100km.robot
* request shall return dmuus with gcp/azure cloudlet provisioned and dmuus farther but < 100km from gcp/azure - findCloudlet_dmuus_dmuusFartherThanGcpAzureLessThan100km.robot
* request shall return dmuus with gcp cloudlet provisioned and dmuus farther but < 100km than gcp - findCloudlet_dmuus_dmuusFartherThanGcpLessThan100km.robot
* request shall return dmuus with azure/gcp cloudlet provisioned and dmuus/azure/gcp same coord - findCloudlet_dmuus_dmuusGcpAzureSameCoord.robot
* request shall return dmuus with gcp cloudlet provisioned and dmuus and gcp same coord - findCloudlet_dmuus_dmuusGcpSameCoord.robot
* request shall return dmuus with gcp cloudlet provisioned and dmuus and gcp same distance away - findCloudlet_dmuus_dmuusGcpSameDistance.robot
* request shall return Invalide GPS with sending out-of-range GPS coord - findCloudlet_invalidParms.robot

### platos FindCloudlet Testcases
* findCloudlet shall return azure with with azure cloudlet provisioned and closer by more than 100km - findCloudlet_platos_azure_azureCloser.robot
* findCloudlet requesting platos app - findCloudlet_platos_findplatosApp.robot
* request shall return gcp with dmuus farther and > 100km farther than gcp - findCloudlet_platos_gcp_gcpCloser.robot
* findCloudlet with various missing override parms - findCloudlet_platos_missingParms.robot
* request shall return error when sending FindCloudlet for app with permits_platform_apps=False - findCloudlet_platos_permitsPlatformAppsFalse.robot
* request shall return error when sending FindCloudlet for app without permits_platform_apps - findCloudlet_platos_permitsPlatformAppsMissing.robot
* request shall return dmuus with azure cloudlet provisioned and dmuus closer and > 100km from request - findCloudlet_platos_dmuus_dmuusCloserThanAzureGreaterThan100km.robot
* request shall return dmuus with gcp/azure cloudlet provisioned and dmuus closer and < 100km from request - findCloudlet_platos_dmuus_dmuusCloserThanGcpAzureLessThan100km.robot
* request shall return dmuus with gcp cloudlet provisioned and dmuus closer and < 100km from request - findCloudlet_platos_dmuus_dmuusCloserThanGcpLessThan100km.robot
