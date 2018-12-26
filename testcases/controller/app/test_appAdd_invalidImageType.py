#!/usr/local/bin/python3

# EDGECLOUD-192 - able to create an app with invalid imagetype and accesslayer - fixed
#
# create app with invalid image_type
# verify error of 'invalid Image Type' is received
# 

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

from MexController import mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'
access_ports = 'tcp:1'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.Controller(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )

    def test_CreateInvalidImageType(self):
        # [Documentation] App - User shall not be able to create an app with nd invalid value
        # ... create an app with imagetype=3 and no other parms
        # ... verify 'invalid ImageType' is received

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=9,
                                      app_name=app_name,
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      default_flavor_name=flavor_name)

        error = None
        try:                               
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'invalid ImageType', 'error details')
        expect_equal(found_app, False, 'find app')
        expect_equal(len(apps_post), len(apps_pre), 'num developer')
                
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

