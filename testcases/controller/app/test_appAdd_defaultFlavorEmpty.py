#!/usr/local/bin/python3

#
# create app with default empty and missing 
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
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
app_name = 'app' + stamp
app_version = '1.0'
access_ports = 'tcp:1'
docker = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
qcow_image = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.MexController(controller_address=controller_address,
                                                       # root_cert=mex_root_cert,
                                                       # key=mex_key,
                                                       # client_cert=mex_cert
                                                       )

    #        self.developer = mex_controller.Developer(developer_org_name=developer_name)#,
    #                                                  #developer_address=developer_address,
    #                                                  #developer_email=developer_email)
    #        self.controller.create_developer(self.developer.developer)

    # removed with EDGECLOUD-3103
    # ECQ-798

    def test_CreateAppDefaultFlavorEmpty_Docker(self):

    # [Documentation] App - User shall be not be able to create app with empty defaultflavor and type Docker
    # ... create an app with empty default flavor and type Docker
    # ... verify 'Specified flavor not found' is received

    # print the existing apps
      app_pre = self.controller.show_apps()

    # create the app with no parms
      error = None
      app = mex_controller.App(image_type='ImageTypeDocker',
                             app_name=app_name,
                             access_ports=access_ports,
                             app_version=app_version,
                             cluster_name='dummyCluster',
                             developer_org_name=developer_name,
                             default_flavor_name='')
      try:
        resp = self.controller.create_app(app.app)
      except grpc.RpcError as e:
        logging.info('got exception ' + str(e))
        error = e

    # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Default flavor must be specified', 'error details')
        assert_expectations()

    # removed with EDGECLOUD-3103
    # ECQ-799


    def test_CreateAppDefaultFlavorEmpty_QCOW(self):
    # [Documentation] App - User shall be not be able to create app with empty defaultflavor and type QCOW
    # ... create an app with empty default flavor and type QCOW
    # ... verify 'Specified flavor not found' is received

    # print the existing apps
       app_pre = self.controller.show_apps()

    # create the app with no parms
       error = None
       app = mex_controller.App(image_type='ImageTypeQCOW',
                             image_path=qcow_image,
                             app_name=app_name,
                             access_ports=access_ports,
                             app_version=app_version,
                             cluster_name='dummyCluster',
                             developer_org_name=developer_name,
                             default_flavor_name='')
       try:
        resp = self.controller.create_app(app.app)
       except grpc.RpcError as e:
        logger.info('got exception ' + str(e))
        error = e

    # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
    # expect_equal(error.details(), 'Specified default flavor not found', 'error details')
        expect_equal(error.details(), 'Default flavor must be specified', 'error details')
    # expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    # removed with EDGECLOUD-3103
    # ECQ-800


    def test_CreateAppDefaultFlavorNotExist_Docker(self):
    # [Documentation] App - User shall be not be able to create app with no defaultflavor and type Docker
    # ... create an app with no default flavor and type Docker
    # ... verify 'Specified flavor not found' is received

    # print the existing apps
        app_pre = self.controller.show_apps()

    # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                             app_name=app_name,
                             access_ports=access_ports,
                             image_path=docker,
                             app_version=app_version,
                             cluster_name='dummyCluster',
                             developer_org_name=developer_name,
                             use_defaults=False
                             )
        try:
         resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
         logger.info('got exception ' + str(e))
         error = e

    # print the cluster instances after error
         app_post = self.controller.show_apps()

         expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
    # expect_equal(error.details(), 'Specified default flavor not found', 'error details')
         expect_equal(error.details(), 'Default flavor must be specified', 'error details')
    # expect_equal(len(app_pre), len(app_post), 'same number of apps')
         assert_expectations()

    # removed with EDGECLOUD-3103
    #   ECQ-801


    def test_CreateAppDefaultFlavorNotExist_QCOW(self):
    # [Documentation] App - User shall be not be able to create app with empty defaultflavor and type QCOW
    # ... create an app with empty default flavor and type QCOW
    # ... verify 'Specified flavor not found' is received

       # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeQCOW',
                             image_path=qcow_image,
                             app_name=app_name,
                             access_ports=access_ports,
                             app_version=app_version,
                             cluster_name='dummyCluster',
                             developer_org_name=developer_name,
                             # image_path='imagepath#md5:12345678901234567890123456789012',
                             use_defaults=False
                             )
        try:
         resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
         logger.info('got exception ' + str(e))
         error = e

    # print the cluster instances after error
         app_post = self.controller.show_apps()

         expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
    # expect_equal(error.details(), 'Specified default flavor not found', 'error details')
         expect_equal(error.details(), 'Default flavor must be specified', 'error details')
    # expect_equal(len(app_pre), len(app_post), 'same number of apps')
         assert_expectations()


@classmethod
def tearDownClass(self):
    self.controller.delete_developer(self.developer.developer)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())
