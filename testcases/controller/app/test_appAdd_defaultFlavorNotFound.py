#!/usr/local/bin/python3

#
# create app with default empty not found in ShowFlavor 
# verify '"Specified default flavor not found"' is received
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
developer_name = 'mrdeveloper' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'

app_name = 'app' + stamp
app_version = '1.0'
access_ports = 'tcp:1'
qcow_image = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'

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

#        self.developer = mex_controller.Developer(developer_org_name=developer_name)#,
#                                                  #developer_address=developer_address,
#                                                  #developer_email=developer_email)
#        self.controller.create_developer(self.developer.developer) 

    def test_CreateAppDefaultFlavorNotFound_Docker(self):
        # [Documentation] App - User shall be not be able to create app with unknown defaultflavor and type Docker
        # ... create an app with unknown default flavor and type Docker
        # ... verify 'Specified flavor not found' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 app_name=app_name,
                                 app_version=app_version,
                                 developer_org_name=developer_name,
                                 default_flavor_name='notfound')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Specified default flavor not found', 'error details')
        expect_equal(error.details(), 'Flavor key {"name":"notfound"} not found', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppDefaultFlavorNotFound_QCOW(self):
        # [Documentation] App - User shall be not be able to create app with unknown defaultflavor and type QCOW
        # ... create an app with unknown default flavor and type QCOW
        # ... verify 'Specified flavor not found' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeQCOW',
                                 image_path=qcow_image,
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 app_name=app_name,
                                 app_version=app_version,
                                 developer_org_name=developer_name,
                                 default_flavor_name='notfound')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Specified default flavor not found', 'error details')
        expect_equal(error.details(), 'Flavor key {"name":"notfound"} not found', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

#    @classmethod
#    def tearDownClass(self):
#        self.controller.delete_developer(self.developer.developer)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

