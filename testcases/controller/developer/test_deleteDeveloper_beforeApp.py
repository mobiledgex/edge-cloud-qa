#!/usr/local/bin/python3

#
# attempt to delete developer before the app
# verify 'Developer in use by Application' error is received
# 

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

import MexController as mex_controller

stamp = str(time.time())
controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'flavor' + stamp
ram = 1024
vcpus = 1
disk = 1
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.MexController(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )

        self.developer = mex_controller.Developer(developer_name=developer_name)
#                                                  developer_address=developer_address,
#                                                  developer_email=developer_email)
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk)

        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      app_version=app_version,
                                      cluster_name=cluster_name,
                                      access_ports='tcp:1',
                                      developer_name=developer_name,
                                      default_flavor_name=flavor_name)

        self.controller.create_developer(self.developer.developer) 
        self.controller.create_flavor(self.flavor.flavor)
        #self.controller.create_cluster(self.cluster.cluster)
        self.controller.create_app(self.app.app)

    def test_DeleteDeveloperBeforeApp(self):
        # print developers before delete
        developer_pre = self.controller.show_developers()

        # delete developer
        error = None
        try:
            self.controller.delete_developer(self.developer.developer)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print developers after delete
        developer_post = self.controller.show_developers()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Developer in use by Application', 'error details')
        expect_equal(len(developer_post), len(developer_pre), 'num developer')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_app(self.app.app)
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_flavor(self.flavor.flavor)
        self.controller.delete_developer(self.developer.developer)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

