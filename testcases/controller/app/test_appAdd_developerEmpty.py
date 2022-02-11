#!/usr/local/bin/python3

#
# create app with developer empty and missing 
# verify 'Invalid developer name' is received
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

access_ports = 'tcp:1'
stamp = str(time.time())
app_name = 'app' + stamp
flavor_name = 'x1.medium'
cluster_name = 'cluster' + stamp
qcow_image = 'https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d'
docker_image = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:6.0'

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

    # ECQ-804
    def test_CreateAppDeveloperEmpty_Docker(self):
        # [Documentation] App - User shall not be able to create app with empty developername and type Docker
        # ... Create an app with empty developername and type Docker
        # ... verify 'Invalid developer name' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 developer_org_name='',
                                 app_name=app_name,
                                 app_version='1.0',
                                 default_flavor_name=flavor_name,
                                 image_path=docker_image,
                                 #ip_access='IpAccessShared',
                                 use_defaults=False)

        try: 
           resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        #self.controller.delete_app(app.app)

        #found_app = app.exists(app_post)
        #expect_equal(found_app, True, 'find app' + app.app_name)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Invalid developer name', 'error details')
        #expect_equal(error.details(), 'Invalid developer name, name cannot be empty', 'error details')
        #expect_equal(error.details(), 'Invalid organization name', 'error details')
        expect_equal(error.details(), 'Invalid app organization', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    # ECQ-805
    def test_CreateAppDeveloperEmpty_QCOW(self):
        # [Documentation] App - User shall not be able to create app with empty developername and type QCOW
        # ... Create an app with empty developername and type QCOW
        # ... verify 'Invalid developer name' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeQCOW',
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 developer_org_name='',
                                 app_name=app_name,
                                 app_version='1.0',
                                 default_flavor_name=flavor_name,
                                 #image_path='automation.com',
                                 image_path=qcow_image,
                                 #ip_access='IpAccessShared',
                                 use_defaults=False)

        try:
           resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        #self.controller.delete_app(app.app)

        #found_app = app.exists(app_post)
        #expect_equal(found_app, True, 'find app' + app.app_name)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Invalid developer name', 'error details')
        #expect_equal(error.details(), 'Invalid developer name, name cannot be empty', 'error details')
        #expect_equal(error.details(), 'Invalid organization name', 'error details')
        expect_equal(error.details(), 'Invalid app organization', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    # ECQ-806
    def test_CreateAppDeveloperNotExist_Docker(self):
        # [Documentation] App - User shall not be able to create app with no developername and type Docker
        # ... Create an app with no developername and type Docker
        # ... verify 'Invalid developer name' is received 

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 app_name=app_name,
                                 app_version='1.0',
                                 default_flavor_name=flavor_name,
                                 image_path=docker_image,
                                 #ip_access='IpAccessShared',
                                 use_defaults=False
                                 )

        try:
           resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        #self.controller.delete_app(app.app)

        #found_app = app.exists(app_post)
        #expect_equal(found_app, True, 'find app' + app.app_name)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Invalid developer name', 'error details')
        #expect_equal(error.details(), 'Invalid developer name, name cannot be empty', 'error details')
        #expect_equal(error.details(), 'Invalid organization name', 'error details')
        expect_equal(error.details(), 'Invalid app organization', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    # ECQ-807
    def test_CreateAppDeveloperNotExist_QCOW(self):
        # [Documentation] App - User shall not be able to create app with no developername and type QCOW
        # ... Create an app with no developername and type QCOW
        # ... verify 'Invalid developer name' is received 

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeQCOW',
                                 cluster_name='dummyCluster',
                                 access_ports=access_ports,
                                 app_name=app_name,
                                 app_version='1.0',
                                 default_flavor_name=flavor_name,
                                 #image_path='automation.com',
                                 image_path=qcow_image,
                                 #ip_access='IpAccessShared',
                                 use_defaults=False
                                 )

        try:
           resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        #self.controller.delete_app(app.app)

        #found_app = app.exists(app_post)
        #expect_equal(found_app, True, 'find app' + app.app_name)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Invalid developer name', 'error details')
        #expect_equal(error.details(), 'Invalid developer name, name cannot be empty', 'error details')
        #expect_equal(error.details(), 'Invalid organization name', 'error details')
        expect_equal(error.details(), 'Invalid app organization', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

