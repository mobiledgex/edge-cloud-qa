#!/usr/local/bin/python3

#
# delete an app that is in use by an application instance 
# verify 'Application in use by static Application Instance' error is received
# 

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
image_type = 'ImageTypeDocker'
app_name = 'app' + stamp
#app_name = 'server_ping_threaded'
app_version = '1.0'
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
access_ports = 'tcp:1'
cloud_name = 'tmocloud-2'
operator_name = 'tmus'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )

        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
#        self.developer = mex_controller.Developer(developer_name=developer_name)#,
#                                                  #developer_address=developer_address,
#                                                  #developer_email=developer_email)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)
        self.app_instance = mex_controller.AppInstance(app_name=app_name,
                                                  cloudlet_name=cloud_name,
                                                  developer_org_name=developer_name,
                                                  cluster_instance_name='autocluster',
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  operator_org_name=operator_name)

        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      app_version=app_version,
                                      image_path='docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0',
                                      #access_layer='AccessLayerL7',
                                      access_ports=access_ports,
                                      #ip_access='IpAccessShared',
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)

        self.controller.create_flavor(self.flavor.flavor)
#        self.controller.create_developer(self.developer.developer) 
        #self.controller.create_cluster(self.cluster.cluster)
        self.controller.create_app(self.app.app)
        self.controller.create_app_instance(self.app_instance.app_instance)
        self.appinst = self.controller.show_app_instances(self.app_instance.app_instance)
        
    # ECQ-1106
    def test_DeleteApp_appInstance_exists(self):
        # [Documentation] App - User shall not be able to delete an app if in use by application instance 
        # ... delete an app which is in use by an application instance
        # ... verify 'Application in use by static Application Instance' error is received

        # print apps before add
        apps_pre = self.controller.show_apps()
        
        # delete app
        error = None
        try:
            self.controller.delete_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print developers after add
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Application in use by static AppInst', 'error details')
        expect_equal(found_app, True, 'find app')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_app_instance(self.app_instance.app_instance)

        cluster_instance = mex_controller.ClusterInstance(
                                                  cloudlet_name=cloud_name,
                                                  cluster_name=self.appinst[0].real_cluster_name,
                                                  developer_org_name='MobiledgeX',
                                                  operator_org_name=operator_name)

        #self.cluster_instance.cluster_name=self.appinst[0].real_cluster_name
        self.controller.delete_cluster_instance(cluster_instance.cluster_instance)

        self.controller.delete_app(self.app.app)
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

