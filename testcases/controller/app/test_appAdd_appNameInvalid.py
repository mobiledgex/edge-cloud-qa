#!/usr/local/bin/python3

#EDGECLOUD-192
#create an app with app name this is not docker compliant
#verify imagename is docker compliant

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
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'
access_ports = 'tcp:1'

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

    def test_CreateNameAtSymbol(self):
        # [Documentation] App - User shall not be able to create an app with @ in the name (not docker compliant)
        # ... create an app with @ in the app name (not docker compliant) 
        # ... verify 'Invalid app name' is received

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name='andy@dandy',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      default_flavor_name=flavor_name)

        error = None
        try:                               
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid app name', 'error details')
        expect_equal(found_app, False, 'find app')
        #expect_equal(len(apps_post), len(apps_pre), 'num developer')
                
        assert_expectations()

    def test_CreateNameStartUnderscore(self):
        # [Documentation] App - User shall not be able to create an app with name starting with underscore (not docker compliant)
        # ... create an app with app name starting with underscore (not docker compliant)
        # ... verify 'Invalid app name' is received

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name='_andydandy',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      default_flavor_name=flavor_name)

        error = None
        try:                               
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logging.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid app name', 'error details')
        expect_equal(found_app, False, 'find app')
        #expect_equal(len(apps_post), len(apps_pre), 'num developer')
                
        assert_expectations()

    def test_CreateNameParenthesis(self):
        # [Documentation] App - User shall not be able to create an app with () in the name (not docker compliant)
        # ... create an app with app with () in the name (not docker compliant)
        # ... verify 'Invalid app name' is received

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name='andy(and)dandy',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      default_flavor_name=flavor_name)

        error = None
        try:                               
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid app name', 'error details')
        expect_equal(found_app, False, 'find app')
        #expect_equal(len(apps_post), len(apps_pre), 'num developer')
                
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

