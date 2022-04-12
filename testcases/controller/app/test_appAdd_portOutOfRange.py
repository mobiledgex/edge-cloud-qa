#!/usr/local/bin/python3
# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#
# create app with port out of range
# verify 'Port out of range' is received
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

    def test_CreateAppPortRangeDedicated_1(self):
        # [Documentation] App - User shall not be able to create a port of tcp:0 and ipaccess=IpAccessDedicated
        # ... create app with port tcp:0 and IpAccessDedicated
        # ... verify 'Port out of range' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:0')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App ports out of range', 'error details')

        #expect_equal(error.details(), 'Port 0 out of range', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppPortRangeDedicated_2(self):
        # [Documentation] App - User shall not be able to create a port of tcp:-1 and ipaccess=IpAccessDedicated
        # ... create app with port tcp:-1 and IpAccessDedicated
        # ... verify 'Port out of range' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:-1')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Unable to convert port range base value')
        #expect_equal(error.details(), 'App ports out of range', 'error details')

        #expect_equal(error.details(), 'Port -1 out of range', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppPortRangeDedicated_3(self):
        # [Documentation] App - User shall not be able to create a port of tcp:65536 and ipaccess=IpAccessDedicated
        # ... create app with port tcp:65536 and IpAccessDedicated
        # ... verify 'Port out of range' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:65536')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App ports out of range', 'error details')

        #expect_equal(error.details(), 'Port 65536 out of range', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppPortRangeDedicated_4(self):
        # [Documentation] App - User shall not be able to create a port of tcp:1,tcp:65537,tcp:65535 and ipaccess=IpAccessDedicated
        # ... create app with port tcp:1,tcp:65537,tcp:65535 and IpAccessDedicated
        # ... verify 'Port out of range' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:1,tcp:65537,tcp:65535')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App ports out of range', 'error details')

        #expect_equal(error.details(), 'Port 65537 out of range', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

#    def test_CreateAppPortRangeDedicatedShared_1(self):
#        # [Documentation] App - User shall not be able to create a port of udp:0 and ipaccess=IpAccessDedicatedOrShared
#        # ... create app with port udp:0 and IpAccessDedicatedOrShared
#        # ... verify 'Port out of range' is received
#
#        # print the existing apps
#        app_pre = self.controller.show_apps()
#
#        # create the app with no parms
#        error = None
#        app = mex_controller.App(image_type='ImageTypeDocker',
#                                 developer_org_name=developer_name,
#                                 app_name=app_name,
#                                 app_version=app_version,
#                                 ip_access='IpAccessDedicatedOrShared',
#                                 access_ports='udp:0')
#
#        try:
#            resp = self.controller.create_app(app.app)
#        except grpc.RpcError as e:
#            logger.info('got exception ' + str(e))
#            error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        expect_equal(error.details(), 'Port 0 out of range', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppPortRangeDedicateShared_2(self):
#        # [Documentation] App - User shall not be able to create a port of udp:-1 and ipaccess=IpAccessDedicatedOrShared
#        # ... create app with port udp:-1 and IpAccessDedicatedOrShared
#        # ... verify 'Port out of range' is received
#
#        # print the existing apps
#        app_pre = self.controller.show_apps()
#
#        # create the app with no parms
#        error = None
#        app = mex_controller.App(image_type='ImageTypeDocker',
#                                 developer_org_name=developer_name,
#                                 app_name=app_name,
#                                 app_version=app_version,
#                                 ip_access='IpAccessDedicatedOrShared',
#                                 access_ports='udp:-1')
#        try:
#            resp = self.controller.create_app(app.app)
#        except grpc.RpcError as e:
#            logger.info('got exception' + str(e))
#            error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        expect_equal(error.details(), 'Port -1 out of range', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppPortRangeDedicatedShared_3(self):
#        # [Documentation] App - User shall not be able to create a port of udp:65536 and ipaccess=IpAccessDedicatedOrShared
#        # ... create app with port udp:65536 and IpAccessDedicatedOrShared
#        # ... verify 'Port out of range' is received
#
#        # print the existing apps
#        app_pre = self.controller.show_apps()
#
#        # create the app with no parms
#        error = None
#        app = mex_controller.App(image_type='ImageTypeDocker',
#                                 developer_org_name=developer_name,
#                                 app_name=app_name,
#                                 app_version=app_version,
#                                 ip_access='IpAccessDedicatedOrShared',
#                                 access_ports='udp:65536')
#        try:
#            resp = self.controller.create_app(app.app)
#        except grpc.RpcError as e:
#            logger.info('got exception' + str(e))
#            error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        expect_equal(error.details(), 'Port 65536 out of range', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppPortRangeDedicatedShared_4(self):
#        # [Documentation] App - User shall not be able to create a port of udp:1,udp:65537,udp:65535 and ipaccess=IpAccessDedicatedOrShared
#        # ... create app with port udp:1,udp:65537,udp:65535 and IpAccessDedicatedOrShared
#        # ... verify 'Port out of range' is received
#
#        # print the existing apps
#        app_pre = self.controller.show_apps()
#
#        # create the app with no parms
#        error = None
#        app = mex_controller.App(image_type='ImageTypeDocker',
#                                 developer_org_name=developer_name,
#                                 app_name=app_name,
#                                 app_version=app_version,
#                                 ip_access='IpAccessDedicatedOrShared',
#                                 access_ports='udp:1,udp:65537,udp:65535')
#        try:
#            resp = self.controller.create_app(app.app)
#        except grpc.RpcError as e:
#            logger.info('got exception' + str(e))
#            error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        expect_equal(error.details(), 'Port 65537 out of range', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#
if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

