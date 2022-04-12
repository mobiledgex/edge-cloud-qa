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
# create app with invalid digits for AccessLayerL4 and AccessLayerL4L7
# verify 'Failed to convert port A80 to integer: strconv.ParseInt: parsing "A80": invalid syntax' is received
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
#    def test_CreateAppPortInvalidUnknown(self):
#        # [Documentation] App - User shall not be able to create an app with invalid digits in port with ipaccess=IpAccessUnknown
#        # ... create app with invalid digits for IpAccessUnknown
#        # ... verify 'Failed to convert port A80 to integer: strconv.ParseInt: parsing A80: invalid syntax' is received
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
#                                 #ip_access='IpAccessUnknown',
#                                 access_ports='tcp:A80')
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
#        expect_equal(error.details(), 'Failed to convert port A80 to integer: strconv.ParseInt: parsing "A80": invalid syntax', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()

    def test_CreateAppPortInvalidDedicated(self):
        # [Documentation] App - User shall not be able to create an app with invalid digits in port with ipaccess=IpAccessDedicated
        # ... create app with invalid digits for IpAccessDedicated
        # ... verify 'Failed to convert port A80 to integer: strconv.ParseInt: parsing A80: invalid syntax' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
#                                 ip_access='IpAccessDedicated',
                                 access_ports='tcp:A80')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'App ports out of range', 'error details')
        expect_equal(error.details(), 'Unable to convert port range base value', 'error details')
        #expect_equal(error.details(), 'Failed to convert port A80 to integer: strconv.ParseInt: parsing "A80": invalid syntax', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

#    def test_CreateAppPortInvalidDedicatedShared(self):
#        # [Documentation] App - User shall not be able to create an app with invalid digits in port with ipaccess=IpAccessDedicatedOrShared
#        # ... create app with invalid digits for IpAccessDedicatedOrShared
#        # ... verify 'Failed to convert port A80 to integer: strconv.ParseInt: parsing A80: invalid syntax' is received
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
#                                 access_ports='udp:xx')
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
#        expect_equal(error.details(), 'Failed to convert port xx to integer: strconv.ParseInt: parsing "xx": invalid syntax', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppPortInvalidShared(self):
#        # [Documentation] App - User shall not be able to create an app with invalid digits in port with ipaccess=IpAccessShared
#        # ... create app with invalid digits for IpAccessShared
#        # ... verify 'Failed to convert port A80 to integer: strconv.ParseInt: parsing A80: invalid syntax' is received
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
#                                 ip_access='IpAccessShared',
#                                 access_ports='udp:xx')
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
#        expect_equal(error.details(), 'Failed to convert port xx to integer: strconv.ParseInt: parsing "xx": invalid syntax', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

