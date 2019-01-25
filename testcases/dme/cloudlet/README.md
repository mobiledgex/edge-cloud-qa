### FindCloudlet Testcases
* findCloudlet shall return azure with with azure cloudlet provisioned and closer by more than 100km - findCloudlet_azure_azureCloser.robot
* request shall return azure with tmus and gcp/azure cloudlet provisioned and tmus farther and > 100km than azure and gcp and azure closer than gcp - findCloudlet_azure_azureCloserThanTmusGcp_azureGreaterThan100km_gcpGreaterThan100km.robot
* request shall return azure with tmus and gcp/azure cloudlet provisioned and tmus farther but > 100km than azure and < 100km than gcp and azure closer than gcp - findCloudlet_azure_azureCloserThanTmusGcp_azureGreaterThan100km_gcpLessThan100km.robot
* request shall return azure with tmus and gcp/azure cloudlet provisioned and requesting azure - findCloudlet_azure_requestAzure.robot
* findCloudlet with various cookie errors - findCloudlet_cookieError.robot
* request shall return gcp with tmus and gcp/azure cloudlet provisioned and tmus farther and > 100km from gcp and azure and gcp closer than azure - findCloudlet_gcp_GcpCloserThanTmusAzure_gcpGreaterThan100km_azureGreaterThan100km.robot
* request shall return gcp with tmus farther and > 100km farther than gcp - findCloudlet_gcp_gcpCloser.robot
* request shall return gcp with tmus and gcp/azure cloudlet provisioned and tmus farther and > 100km than gcp and < 100km than azure and gcp closer than azure - findCloudlet_gcp_gcpCloserThanTmusAzure_gcpGreaterThan100km_azureLessThan100km.robot
* request shall return gcp with tmus and gcp/azure cloudlet provisioned and requesting gcp - findCloudlet_gcp_requestGcp.robot
* findCloudlet with various missing parms - findCloudlet_missingParms.robot
* request shall return tmus with azure cloudlet closer but no appinst provisioned - findCloudlet_tmus_azureCloser_noAppinst.robot
* request shall return FIND_NOT_FOUND when requesting an operator that doesnt exist - findCloudlet_tmus_cloudletNotFound.robot
* request shall return tmus with gcp cloudlet closer but no appinst provisioned - findCloudlet_tmus_gcpCloser_noAppinst.robot
* request shall return proper cloudlet when multiple cloudlets exist - findCloudlet_tmus_multiple.robot
* request shall return tmus with no gcp/azure provisioned ond same coord as tmocloud-1 - findCloudlet_tmus_noGcpNoAzure.robot
* request shall return tmus with azure cloudlet provisioned and tmus and azure same coord - findCloudlet_tmus_tmusAzureSameCoord.robot
* FindCloudlet shall return tmus with azure cloudlet provisioned and tmus and azure same distance - findCloudlet_tmus_tmusAzureSameDistance.robot
* request shall return tmus with azure cloudlet provisioned and tmus closer and > 100km from request - findCloudlet_tmus_tmusCloserThanAzureGreaterThan100km.robot
* request shall return tmus with azure cloudlet provisioned and tmus closer and < 100km from request - findCloudlet_tmus_tmusCloserThanAzureLessThan100km.robot
* request shall return tmus with gcp/azure cloudlet provisioned and tmus closer and > 100km from request - findCloudlet_tmus_tmusCloserThanGcpAzureGreaterThan100km.robot
* request shall return tmus with gcp/azure cloudlet provisioned and tmus closer and < 100km from request - findCloudlet_tmus_tmusCloserThanGcpAzureLessThan100km.robot
* request shall return tmus with gcp/azure cloudlet provisioned and tmus closer and with large distances - findCloudlet_tmus_tmusCloserThanGcpAzure_largeDistance.robot
* request shall return tmus with gcp cloudlet provisioned and tmus closer and > 100km from request - findCloudlet_tmus_tmusCloserThanGcpGreaterThan100km.robot
* request shall return tmus with gcp cloudlet provisioned and tmus closer and < 100km from request - findCloudlet_tmus_tmusCloserThanGcpLessThan100km.robot
* request shall return tmus with azure cloudlet provisioned and tmus farther but < 100km than azure - findCloudlet_tmus_tmusFartherThanAzureLessThan100km.robot
* request shall return tmus with gcp/azure cloudlet provisioned and tmus farther but < 100km from gcp/azure - findCloudlet_tmus_tmusFartherThanGcpAzureLessThan100km.robot
* request shall return tmus with gcp cloudlet provisioned and tmus farther but < 100km than gcp - findCloudlet_tmus_tmusFartherThanGcpLessThan100km.robot
* request shall return tmus with azure/gcp cloudlet provisioned and tmus/azure/gcp same coord - findCloudlet_tmus_tmusGcpAzureSameCoord.robot
* request shall return tmus with gcp cloudlet provisioned and tmus and gcp same coord - findCloudlet_tmus_tmusGcpSameCoord.robot
* request shall return tmus with gcp cloudlet provisioned and tmus and gcp same distance away - findCloudlet_tmus_tmusGcpSameDistance.robot
* request shall return Invalide GPS with sending out-of-range GPS coord - findCloudlet_invalidParms.robot

### Samsung FindCloudlet Testcases
* findCloudlet shall return azure with with azure cloudlet provisioned and closer by more than 100km - findCloudlet_samsung_azure_azureCloser.robot
* findCloudlet requesting Samsung app - findCloudlet_samsung_findSamsungApp.robot
* request shall return gcp with tmus farther and > 100km farther than gcp - findCloudlet_samsung_gcp_gcpCloser.robot
* findCloudlet with various missing override parms - findCloudlet_samsung_missingParms.robot
* request shall return error when sending FindCloudlet for app with permits_platform_apps=False - findCloudlet_samsung_permitsPlatformAppsFalse.robot
* request shall return error when sending FindCloudlet for app without permits_platform_apps - findCloudlet_samsung_permitsPlatformAppsMissing.robot
* request shall return tmus with azure cloudlet provisioned and tmus closer and > 100km from request - findCloudlet_samsung_tmus_tmusCloserThanAzureGreaterThan100km.robot
* request shall return tmus with gcp/azure cloudlet provisioned and tmus closer and < 100km from request - findCloudlet_samsung_tmus_tmusCloserThanGcpAzureLessThan100km.robot
* request shall return tmus with gcp cloudlet provisioned and tmus closer and < 100km from request - findCloudlet_samsung_tmus_tmusCloserThanGcpLessThan100km.robot
