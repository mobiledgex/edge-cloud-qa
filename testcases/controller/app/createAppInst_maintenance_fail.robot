*** Settings ***
Documentation   CreateClusterInst with cloudlet maintenance failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${region}=  US
${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-2466
#AppInst - error shall be received when creating a docker/direct/shared autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a docker/direct/shared autocluster app instance on the cloudlet 
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2467
#AppInst - error shall be received when creating a docker/direct/dedicated autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a docker/direct/dedicated autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2468
#AppInst - error shall be received when creating a docker/lb/shared autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a docker/lb/shared autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2469
#AppInst - error shall be received when creating a docker/lb/dedicated autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a docker/lb/dedicated autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2470
#AppInst - error shall be received when creating a k8s/lb/shared autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
#   ...  - create a k8s/lb/shared autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2471
#AppInst - error shall be received when creating a k8s/lb/dedicated autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a k8s/lb/dedicated autocluster app instance on the cloudlet
#   ...  - verify proper error is received
###
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2472
#AppInst - error shall be received when creating a helm/lb/shared autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a helm/lb/shared autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2473
#AppInst - error shall be received when creating a helm/lb/dedicated autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a helm/lb/dedicated autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2474
#AppInst - error shall be received when creating a vm/lb/shared autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a vm/lb/shared autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2475
#AppInst - error shall be received when creating a vm/lb/dedicated autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a vm/lb/dedicated autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=loadbalancer
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated  cluster_instance_name=autoclusterxxx
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2476
#AppInst - error shall be received when creating a vm/direct/shared autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a vm/direct/shared autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=direct
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2477
#AppInst - error shall be received when creating a vm/direct/dedicated autocluster app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - put cloudlet in maintenance mode
#   ...  - create a vm/direct/dedicated autocluster app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=direct
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated 
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
# ECQ-3209
AppInst - error shall be received when creating a docker/lb autocluster app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance mode
   ...  - create a docker/lb autocluster app instance on the cloudlet
   ...  - verify proper error is received

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-3210
AppInst - error shall be received when creating a k8s/lb autocluster app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance_state=MaintenanceStartNoFailover
   ...  - create a k8s/lb autocluster app instance on the cloudlet
   ...  - verify proper error is received

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-3211
AppInst - error shall be received when creating a helm/lb autocluster app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance mode
   ...  - create a helm/lb autocluster app instance on the cloudlet
   ...  - verify proper error is received

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

#  ECQ-3212
AppInst - error shall be received when creating a vm/lb autocluster app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - put cloudlet in maintenance mode
   ...  - create a vm/lb autocluster app instance on the cloudlet
   ...  - verify proper error is received

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# direct not supported
# ECQ-2478
#AppInst - error shall be received when creating a docker/direct/shared app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - create docker/shared cluster inst 
#   ...  - put cloudlet in maintenance mode
#   ...  - create a direct app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name} 
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
## ECQ-2479
#AppInst - error shall be received when creating a docker/direct/dedicated app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - create docker/dedicated cluster inst
#   ...  - put cloudlet in maintenance mode
#   ...  - create a direct app instance on the cloudlet
#   ...  - verify proper error is received
#
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated
#
#   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2480
AppInst - error shall be received when creating a docker/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create docker/shared cluster inst
   ...  - put cloudlet in maintenance mode
   ...  - create a lb app instance on the cloudlet
   ...  - verify proper error is received

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2481
AppInst - error shall be received when creating a docker/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create docker/dedicated cluster inst
   ...  - put cloudlet in maintenance mode
   ...  - create a lb autocluster app instance on the cloudlet
   ...  - verify proper error is received

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2482
AppInst - error shall be received when creating a k8s/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/shared cluster inst
   ...  - put cloudlet in maintenance mode
   ...  - create a lb app instance on the cloudlet
   ...  - verify proper error is received

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2483
AppInst - error shall be received when creating a k8s/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/dedicated cluster inst
   ...  - put cloudlet in maintenance mode
   ...  - create a lb app instance on the cloudlet
   ...  - verify proper error is received

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2484
AppInst - error shall be received when creating a helm/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/shared cluster inst
   ...  - put cloudlet in maintenance mode
   ...  - create a helm/lb app instance on the cloudlet
   ...  - verify proper error is received

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2485
AppInst - error shall be received when creating a helm/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/dedicated cluster inst
   ...  - put cloudlet in maintenance mode
   ...  - create a helm/lb app instance on the cloudlet
   ...  - verify proper error is received

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

   Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}
   ${error_msg}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# direct not supported
# ECQ-2486
#AppInst - error shall be received when deleting/updating/refreshing a docker/direct/dedicated app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - create docker/dedicated cluster inst
#   ...  - create a direct app instance on the cloudlet
#   ...  - put cloudlet in maintenance mode
#   ...  - delete/update/refresh the appinst
#   ...  - verify proper error is received
#
#   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]
#
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated
#
#   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#
#   Create App Instance  region=${region}  developer_org_name=${app['data']['key']['organization']}  #cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${app['data']['key']['organization']}
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#
#   # delete appinst
#   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   # update appinst
#   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   #refresh appinst
#   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${operator_name}  #image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  #configs_kind=envVarsYaml  configs_config=${config}
#   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   # delete the appinst
#   ${error_msg4}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}
#   Should Be Equal  ${error_msg4}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   # update appinst
#   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}
#   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   #refresh appinst
#   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${operator_name}  #image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
#   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  
#   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2487
AppInst - error shall be received when deleting/updating/refreshing a docker/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create docker/shared cluster inst
   ...  - create a lb app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete/update/refresh the appinst
   ...  - verify proper error is received

   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessShared

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   # delete appinst
   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}  #image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  #configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   # delete appinst
   ${error_msg4}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}  #image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=direct
   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2488
AppInst - error shall be received when deleting/updating/refreshing a docker/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create docker/dedicated cluster inst
   ...  - create a lb app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete the appinst
   ...  - verify proper error is received

   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=docker  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   # delete appinst
   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   # delete appinst
   ${error_msg3}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2489
AppInst - error shall be received when deleting/updating/refreshing a k8s/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/shared cluster inst
   ...  - create a lb app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete/update/refresh the appinst
   ...  - verify proper error is received

   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   # delete appinst
   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   # delete appinst
   ${error_msg4}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg4}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2490
AppInst - error shall be received when deleting/updating/refreshing a k8s/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/dedicated cluster inst
   ...  - create a lb app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete/update/refresh the appinst
   ...  - verify proper error is received

   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeDocker  deployment=kubernetes  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   # delete appinst
   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   # delete appinst
   ${error_msg4}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg4}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2491
AppInst - error shall be received when deleting/updating/refreshing a helm/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/shared cluster inst
   ...  - create a helm/lb app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete/update/refresh the appinst
   ...  - verify proper error is received

   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   # delete appinst
   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   # delete appinst
   ${error_msg4}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg4}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2492
AppInst - error shall be received when deleting/updating/refreshing a helm/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create k8s/dedicated cluster inst
   ...  - create a helm/lb app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete/update/refresh the appinst
   ...  - verify proper error is received

   ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeHelm  deployment=helm  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   # delete appinst
   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg2}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg3}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg3}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   # delete appinst
   ${error_msg4}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg4}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   # update appinst
   ${error_msg5}=  Run Keyword And Expect Error  *  Update App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  configs_kind=envVarsYaml  configs_config=${config}  token=${tokendev}
   Should Be Equal  ${error_msg5}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   #refresh appinst
   Update App  region=${region}  official_fqdn=x.com  developer_org_name=${org_name_dev}  token=${tokendev}
   ${error_msg6}=  Run Keyword And Expect Error  *  Refresh App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg6}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2493
AppInst - error shall be received when deleting a vm/lb/shared app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create a vm/lb/shared autocluster app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete the appinst
   ...  - verify proper error is received

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessShared  

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# ECQ-2494
AppInst - error shall be received when deleting a vm/lb/dedicated app inst while cloudlet is maintenance mode
   [Documentation]
   ...  - create a vm/lb/dedicated autocluster app instance on the cloudlet
   ...  - put cloudlet in maintenance mode
   ...  - delete the appinst
   ...  - verify proper error is received

   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated 

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover  token=${tokenop}

   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart  token=${tokenop}

   ${error_msg2}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}  token=${tokendev}
   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

# direct not supported
# ECQ-2495
#AppInst - error shall be received when deleting a vm/direct/dedicated app inst while cloudlet is maintenance mode
#   [Documentation]
#   ...  - create a vm/direct/dedicated autocluster app instance on the cloudlet
#   ...  - put cloudlet in maintenance mode
#   ...  - delete the appinst
#   ...  - verify proper error is received
#
#   ${app}=  Create App  region=${region}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  deployment=vm  app_version=1.0   access_type=direct
#
#   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  #autocluster_ip_access=IpAccessDedicated
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStartNoFailover
#
#   ${error_msg}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')
#
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation
#   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=MaintenanceStart
#
#   ${error_msg2}=  Run Keyword And Expect Error  *  Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  app_name=${app['data']['key']['name']}  developer_org_name=${app['data']['key']['organization']}  app_version=${app['data']['key']['version']}
#   Should Be Equal  ${error_msg2}  ('code=400', 'error={"message":"Cloudlet under maintenance, please try again later"}')

*** Keywords ***
Setup
   Create Flavor  region=${region}

   Create Org  orgtype=operator
   RestrictedOrg Update
   Create Cloudlet  region=${region} 

   ${operator_name}=  Get Default Organization Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${flavor_name_default}=  Get Default Flavor Name
   ${org_name_dev}=  Set Variable  ${operator_name}_dev

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com
   ${usernamedev_epoch}=  Catenate  SEPARATOR=  ${username}  dev  ${epoch}
   ${emaildev}=  Catenate  SEPARATOR=  ${username}  dev  +  ${epoch}  @gmail.com

   Create Org  orgname=${org_name_dev}  orgtype=developer
   Create Billing Org  billing_org_name=${org_name_dev}

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name}  role=OperatorManager
   Adduser Role  username=${usernamedev_epoch}  orgname=${org_name_dev}  role=DeveloperManager

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=${usernamedev_epoch}  password=${password}

   Set Suite Variable  ${flavor_name_default}
   Set Suite Variable  ${operator_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${tokendev}
   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${org_name_dev}

Teardown
   Update Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  maintenance_state=NormalOperation  token=${tokenop}
   Cleanup Provisioning
