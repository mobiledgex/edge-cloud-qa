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
# create app with invalud ports format and IpAccessDedicated IpAccessDedicatedOrShared IpAccessShared
# verify 'Invalid Access Ports format, expected proto:port but was tcp80' is received
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

    def test_CreateAppInvalidFormatIpAccessDedicated_1(self):
        # [Documentation] App - User shall not be able to create an app with accessport tcp80 and IpAccessDedicated
        # ... create app with invalid ports format of tcp80 and IpAccessDedicated
        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp80' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp80')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid AccessPorts format \'tcp80\'', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppInvalidFormatIpAccessDedicated_2(self):
        # [Documentation] App - User shall not be able to create an app with accessport tcp80: and IpAccessDedicated
        # ... create app with invalid ports format of tcp80 and IpAccessDedicated
        # ... verify 'tcp80 is not a supported Protocol' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp80:')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Unable to convert port range base value', 'error details')
        #expect_equal(error.details(), 'App ports out of range', 'error details')

        #expect_equal(error.details(), 'tcp80 is not a supported Protocol', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppInvalidFormatIpAccessDedicated_3(self):
        # [Documentation] App - User shall not be able to create an app with accessport tcp:80: and IpAccessDedicated
        # ... create app with invalid ports format of tcp:80: and IpAccessDedicated
        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:80:')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid AccessPorts annotation  for port 80, expected format is either key or key=val', 'error details')
        #expect_equal(error.details(), 'Invalid AccessPorts format \'tcp:80:\'', 'error details')
        #expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was tcp', 'error details')

        #expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was tcp', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppInvalidFormatIpAccessDedicated_4(self):
        # [Documentation] App - User shall not be able to create an app with accessport : and IpAccessDedicated
        # ... create app with invalid ports format of : and IpAccessDedicated
        # ... verify ' is not a supported Protocol'' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports=':')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Unable to convert port range base value', 'error details')
        #expect_equal(error.details(), 'App ports out of range', 'error details')

        #expect_equal(error.details(), ' is not a supported Protocol', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppInvalidFormatIpAccessDedicated_5(self):
        # [Documentation] App - User shall not be able to create an app with accessport with special chars and IpAccessDedicated
        # ... create app with invalid ports format of '<>()!' and IpAccessDedicated
        # ... verify 'Invalid Access Ports format, expected proto:port but was <>()!' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='<>()!')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid AccessPorts format \'<>()!\'', 'error details')
        #expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was <>()!', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppInvalidFormatIpAccessDedicated_6(self):
        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80,tcp:81,tcp82' and IpAccessDedicated
        # ... create app with invalid ports format of 'tcp:80,tcp:81,tcp82' and IpAccessDedicated
        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp82' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:80,tcp:81,tcp82')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid AccessPorts format \'tcp82\'', 'error details')
        #expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was tcp82', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

    def test_CreateAppInvalidFormatIpAccessDedicated_7(self):
        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80,tcp:81,' and IpAccessDedicated
        # ... create app with invalid ports format of 'tcp:80,tcp:81,' and IpAccessDedicated
        # ... verify 'Invalid Access Ports format, expected proto:port but was ' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 #ip_access='IpAccessDedicated',
                                 access_ports='tcp:80,tcp:81,')
        try:
            resp = self.controller.create_app(app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid AccessPorts format \'\'', 'error details')
        #expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was ', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        assert_expectations()

#    def test_CreateAppInvalidFormatlIpAccessDedicatedOrShared_1(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'udp80' and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of 'udp80' and IpAccessDedicatedOrShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was udp80' is received
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
#                                 #ip_access='IpAccessDedicatedOrShared',
#                                 access_ports='udp80')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was udp80', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessDedicatedOrShared_2(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp80:' and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of 'tcp80:' and IpAccessDedicatedOrShared
#        # ... verify 'tcp80 is not a supported Protocol' is received
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
#                                 #ip_access='IpAccessDedicatedOrShared',
#                                 access_ports='tcp80:')
#        try:
#            resp = self.controller.create_app(app.app)
#        except grpc.RpcError as e:
#            logging.info('got exception ' + str(e))
#            error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        expect_equal(error.details(), 'tcp80 is not a supported Protocol', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormaIpAccessDedicatedOrShared_3(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80:' and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of 'tcp80:' and IpAccessDedicatedOrShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp' is received
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
#                                 access_ports='tcp:80:')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was tcp', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessDedicatedOrShared_4(self):
#        # [Documentation] App - User shall not be able to create an app with accessport ':' and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of ':' and IpAccessDedicatedOrShared
#        # ... verify ' is not a supported Protocol'' is received
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
#                                 access_ports=':')
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
#        expect_equal(error.details(), ' is not a supported Protocol', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessDedicatedOrShared_5(self):
#        # [Documentation] App - User shall not be able to create an app with accessport with special chars and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of special chars and IpAccessDedicatedOrShared
#        # ... verify ' is not a supported Protocol' is received
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
#                                 access_ports='<>()!')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port[-endport] but was <>()!', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessDedicatedOrShared_6(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80,tcp:81,tcp82' and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of 'tcp:80,tcp:81,tcp82' and IpAccessDedicatedOrShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp82' is received
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
#                                 access_ports='tcp:80,tcp:81,tcp82')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was tcp82', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessDedicatedOrShared_7(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80,tcp:81,' and IpAccessDedicatedOrShared
#        # ... create app with invalid ports format of 'tcp:80,tcp:81,' and IpAccessDedicatedOrShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was' is received
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
#                                 access_ports='tcp:80,tcp:81,')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was ', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatlIpAccessShared_1(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'udp80' and IpAccessShared
#        # ... create app with invalid ports format of 'udp80' and IpAccessShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was udp80' is received
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
#                                 access_ports='udp80')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was udp80', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessShared_2(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp80:' and IpAccessShared
#        # ... create app with invalid ports format of 'tcp80:' and IpAccessShared
#        # ... verify 'tcp80 is not a supported Protocol' is received
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
#                                 access_ports='tcp80:')
#        try:
#            resp = self.controller.create_app(app.app)
#        except grpc.RpcError as e:
#            logging.info('got exception ' + str(e))
#            error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        expect_equal(error.details(), 'tcp80 is not a supported Protocol', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormaIpAccessShared_3(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80:' and IpAccessShared
#        # ... create app with invalid ports format of 'tcp:80:' and IpAccessShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp' is received
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
#                                 access_ports='tcp:80:')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was tcp', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessShared_4(self):
#        # [Documentation] App - User shall not be able to create an app with accessport ':' and IpAccessShared
#        # ... create app with invalid ports format of ':' and IpAccessShared
#        # ... verify ' is not a supported Protocol' is received
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
#                                 access_ports=':')
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
#        expect_equal(error.details(), ' is not a supported Protocol', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessShared_5(self):
#        # [Documentation] App - User shall not be able to create an app with accessport with special chars and IpAccessShared
#        # ... create app with invalid ports format with special chars and IpAccessShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was <>()!' is received
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
#                                 access_ports='<>()!')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was <>()!', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessShared_6(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80,tcp:81,tcp82' and IpAccessShared
#        # ... create app with invalid ports format of 'tcp:80,tcp:81,tcp82' and IpAccessShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was tcp82' is received
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
#                                 access_ports='tcp:80,tcp:81,tcp82')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was tcp82', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        assert_expectations()
#
#    def test_CreateAppInvalidFormatIpAccessShared_7(self):
#        # [Documentation] App - User shall not be able to create an app with accessport 'tcp:80,tcp:81,' and IpAccessShared
#        # ... create app with invalid ports format of 'tcp:80,tcp:81,' and IpAccessShared
#        # ... verify 'Invalid Access Ports format, expected proto:port but was ' is received
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
#                                 access_ports='tcp:80,tcp:81,')
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
#        expect_equal(error.details(), 'Invalid Access Ports format, expected proto:port but was ', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#
#
if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

