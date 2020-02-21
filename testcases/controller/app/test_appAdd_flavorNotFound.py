#!/usr/local/bin/python3

#
# create app with no cluster and default flavor not found in ShowFlavor
# verify 'Specified default flavor not found' is received
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

stamp = str(int(time.time()))
#app_name = 'appname' + stamp
app_name = 'server_ping_threaded'
app_version = '5.0'
#developer_name = 'developer' + stamp
developer_name = 'mobiledgex'

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
        self.developer = mex_controller.Developer(developer_name=developer_name,
                                                  )
        #self.controller.create_developer(self.developer.developer) 

    def test_CreateAppImageTypeOnlyImageTypeUnknown(self):
        # [Documentation] App - User shall not be able to create an app with no cluster and defaultflavor that doesnot exist 
        # ... create app with no cluster and default flavor not found in ShowFlavor
        # ... verify 'Specified flavor not found' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 default_flavor_name='flavorNotFound',
                                 access_ports=access_ports,
                                 use_defaults=False)
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'No cluster flavors with node flavor flavorNotFound found', 'error details')
        #expect_equal(error.details(), 'Specified default flavor not found', 'error details')
        expect_equal(error.details(), 'Flavor key {"name":"flavorNotFound"} not found', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

#    @classmethod
#    def tearDownClass(self):
#        self.controller.delete_developer(self.developer.developer)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

