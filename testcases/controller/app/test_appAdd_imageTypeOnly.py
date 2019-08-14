#!/usr/local/bin/python3

#
# create app with imageType only 
# verify proper error is received
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
app_name = 'appname' + stamp
app_version = '1.0'
developer_name = 'developer' + stamp
docker = 'docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
access_ports = 'tcp:1'
qcow_image = 'https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

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

    def test_CreateAppImageTypeOnlyImageTypeUnknown(self):
        # [Documentation] App - User shall not be able to an app with unknown imagetype
        # ... create an app with imagetype=ImageTypeUnknown
        # ... verify 'unknown image type ImageTypeUnknown' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeUnknown',
                                 developer_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 access_ports='tcp:1',
                                 use_defaults=False
        )
        try:
            resp = self.controller.create_app(app.app)
        #except Exception as e:
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'unknown image type IMAGE_TYPE_UNKNOWN', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppImageTypeOnlyImageTypeDocker(self):
        # [Documentation] App - User shall not be able to an app with imagetype only of Docker
        # ... create an app with imagetype only of Docker
        # ... verify 'Specified flavor not found' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_name=developer_name,
                                 app_name=app_name,
                                 image_path=docker,
                                 app_version=app_version,
                                 use_defaults=False
        )
        try:
            resp = self.controller.create_app(app.app)
        #except Exception as e:
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'DefaultFlavor is required if Cluster is not specified', 'error details')
        #expect_equal(error.details(), 'Specified default flavor not found', 'error details')
        expect_equal(error.details(), 'Specified flavor not found', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppImageTypeOnlyImageTypeQCOW(self):
        # [Documentation] App - User shall not be able to an app with imagetype only of QCOW
        # ... create an app with imagetype only of QCOW
        # ... verify 'Specified flavor not found' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeQCOW',
                                 #image_path=qcow_image,
                                 developer_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 use_defaults=False
        )
        try:
            resp = self.controller.create_app(app.app)
        #except Exception as e:
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'DefaultFlavor is required if Cluster is not specified', 'error details')
        #expect_equal(error.details(), 'Specified default flavor not found', 'error details')
        #expect_equal(error.details(), 'Specified flavor not found', 'error details')
        expect_equal(error.details(), 'imagepath is required for imagetype IMAGE_TYPE_QCOW', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppImageTypeOnlyImageTypeWrong(self):
        # [Documentation] App - User shall not be able to an app with imagetype only and invalid value
        # ... create an app with imagetype=3 and no other parms
        # ... verify 'invalid ImageType' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type=3,
                                 developer_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 access_ports='tcp:1',
                                 use_defaults=False
        )
        try:
            resp = self.controller.create_app(app.app)
        #except Exception as e:
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'invalid ImageType', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

