#!/usr/local/bin/python3

#
# create app with developer that does not exist in ShowDeveloper 
# verify 'Specified developer not found' is received
# 
# updated to allow apps to be created with unknown developer

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

access_ports = 'tcp:1'
stamp = str(time.time())
flavor_name = 'x1.small' + stamp
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
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.controller.create_flavor(self.flavor.flavor)

    def test_CreateAppDeveloperNotFound_Docker(self):
        # [Documentation] App - User shall be able to create app with unkown developername and type Docker
        # ... Create an app with unknown developername and type Docker
        # ... verify app is created

        # updated to allow apps to be created with unknown developer

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 app_name = 'dummpyApp',
                                 access_ports=access_ports,
                                 app_version = '1.0',
                                 cluster_name='dummyCluster',
                                 developer_org_name='developerNotFound',
                                 default_flavor_name = flavor_name
                                )
        #try:
        #    resp = self.controller.create_app(app.app)
        #except grpc.RpcError as e:
        #    logger.info('got exception ' + str(e))
        #    error = e

        self.controller.create_app(app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        found_app = app.exists(app_post)

        self.controller.delete_app(app.app)
        
        expect_equal(found_app, True, 'find app')

        #expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Specified developer not found', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppDeveloperNotFound_QCOW(self):
        # [Documentation] App - User shall be able to create app with unkown developername and type QCOW
        # ... Create an app with unknown developername and type QCOW 
        # ... verify app is created

        # updated to allow apps to be created with unknown developer

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeQCOW',
                                 image_path=qcow_image,
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 app_name = 'dummpyApp',
                                 app_version = '1.0',
                                 developer_org_name='developerNotFound'
                                )
        #try:
        #    resp = self.controller.create_app(app.app)
        #except grpc.RpcError as e:
        #    logger.info('got exception ' + str(e))
        #    error = e

        self.controller.create_app(app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        found_app = app.exists(app_post)

        self.controller.delete_app(app.app)

        expect_equal(found_app, True, 'find app')

        #expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Specified developer not found', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

